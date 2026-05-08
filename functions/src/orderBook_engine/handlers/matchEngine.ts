import { HttpsError } from "firebase-functions/https";
import { getOrdersByStartup } from "../../orders/repositories/ordersRepositories";
import { Order, OrderStatus, OrderType } from "../../orders/types/orderType";
import { MatchesExecuted, MatchOrder } from "../types/matchTypes";
import { db } from "../../startups/shared/firebase";
import {
  TokenWalletType,
  TransactionModel,
} from "../../exchange/types/walletType";
import { Timestamp } from "firebase-admin/firestore";
import { StartupPriceHistory } from "../../startups/types/startupType";

export async function matchOrders(startupId: string): Promise<MatchesExecuted> {
  const startupOrders: Order[] = await getOrdersByStartup(startupId);
  let startupOpenOrders: Order[] = [];
  startupOrders.map((o) => {
    if (o.status === OrderStatus.open || o.status === OrderStatus.partially) {
      startupOpenOrders.push(o);
    }
  });

  if (!startupOpenOrders) return { matchesExecuted: 0 };
  let buyOrders: Order[] = [];
  let sellOrders: Order[] = [];
  for (const o of startupOpenOrders) {
    if (OrderType.buy === o.type) {
      buyOrders.push(o);
    } else if (OrderType.sell === o.type) {
      sellOrders.push(o);
    } else {
      throw new HttpsError(
        "invalid-argument",
        'Ordem fornecida não tem um tipo válido ("buy" | "sell")',
      );
    }
  }
  const matchingOrders: MatchOrder[] = findMatchingOrders(
    buyOrders,
    sellOrders,
  );

  let matchesExecutedCount: number = 0;
  for (const mo of matchingOrders) {
    try {
      const { qty, price } = resolveMatch(mo.buy, mo.sell);
      await settleMatch(mo.buy, mo.sell, qty, price);
      matchesExecutedCount++;
    } catch (e) {
      console.error(
        "[matchOrders] Erro ao liquidar par de ordens, pulando para o próximo:",
        e,
      );
    }
  }

  return { matchesExecuted: matchesExecutedCount };
}

function findMatchingOrders(buys: Order[], sells: Order[]): MatchOrder[] {
  if (buys.length == 0 || sells.length == 0) {
    return [];
  }
  buys.sort((a, b) =>
    b.price - a.price !== 0
      ? b.price - a.price
      : a.createdAt.toMillis() - b.createdAt.toMillis(),
  );
  sells.sort((a, b) =>
    b.price - a.price == 0
      ? a.price - b.price
      : a.createdAt.toMillis() - b.createdAt.toMillis(),
  );
  let matchingOrders: MatchOrder[] = [];
  for (let i: number = 0; i < buys.length; i++) {
    for (let j: number = 0; j < sells.length; j++) {
      if (buys[i].price >= sells[j].price) {
        if (buys[i].user_id === sells[j].user_id) {
          continue;
        }
        matchingOrders.push({ buy: buys[i], sell: sells[j] } as MatchOrder);
      }
    }
  }
  return matchingOrders;
}

function resolveMatch(buy: Order, sell: Order) {
  const remainingBuy = buy.quantity - buy.quantity_filled;
  const remainingSell = sell.quantity - sell.quantity_filled;

  const qty = Math.min(remainingBuy, remainingSell);

  const price = sell.price;
  return { qty, price };
}

async function settleMatch(
  buy: Order,
  sell: Order,
  qty: number,
  price: number,
) {
  await db.runTransaction(async (tx) => {
    const walletRefBuyer = db.collection("wallets").doc(buy.user_id!);
    const walletRefSeller = db.collection("wallets").doc(sell.user_id!);
    const buyOrderRef = db.collection("orders").doc(buy.id);
    const sellOrderRef = db.collection("orders").doc(sell.id);

    const [buyerSnap, sellerSnap, buyOrderSnap, sellOrderSnap] =
      await Promise.all([
        tx.get(walletRefBuyer),
        tx.get(walletRefSeller),
        tx.get(buyOrderRef),
        tx.get(sellOrderRef),
      ]);

    const buyerWallet = buyerSnap.data() as TokenWalletType;
    const sellerWallet = sellerSnap.data() as TokenWalletType;
    const totalValue = qty * price;

    // Validações de consistência
    const sellerHolding = sellerWallet.holdings.find(
      (h) => h.startupId === sell.startup_id,
    );
    if (!sellerHolding || sellerHolding.blockedTokenBalance < qty) {
      console.error(
        "[settleMatch] Inconsistência: blockedTokenBalance insuficiente",
        {
          sellOrderId: sell.id,
          buyOrderId: buy.id,
          expected: qty,
          found: sellerHolding?.blockedTokenBalance ?? 0,
        },
      );
      return;
    }
    if (buyerWallet.blockedBalance < totalValue) {
      console.error(
        "[settleMatch] Inconsistência: blockedBalance insuficiente",
        {
          buyOrderId: buy.id,
          expected: totalValue,
          found: buyerWallet.blockedBalance,
        },
      );
      return;
    }

    // transferFunds
    tx.update(walletRefBuyer, {
      blockedBalance: buyerWallet.blockedBalance - totalValue,
    });
    tx.update(walletRefSeller, {
      availableBalance: sellerWallet.availableBalance + totalValue,
    });

    // transferTokens
    const updatedSellerHoldings = sellerWallet.holdings.map((h) =>
      h.startupId === sell.startup_id
        ? {
            ...h,
            blockedTokenBalance: h.blockedTokenBalance - qty,
            avgPrice:
              (h.tokenBalance * h.avgPrice + qty * price) /
              (h.tokenBalance + qty),
          }
        : h,
    );
    tx.update(walletRefSeller, { holdings: updatedSellerHoldings });

    const buyerHoldingExists = buyerWallet.holdings.some(
      (h) => h.startupId === buy.startup_id,
    );
    const updatedBuyerHoldings = buyerHoldingExists
      ? buyerWallet.holdings.map((h) =>
          h.startupId === buy.startup_id
            ? {
                ...h,
                tokenBalance: h.tokenBalance + qty,
                avgPrice:
                  (h.tokenBalance * h.avgPrice + qty * price) /
                  (h.tokenBalance + qty),
              }
            : h,
        )
      : [
          ...buyerWallet.holdings,
          {
            tokenBalance: qty,
            blockedTokenBalance: 0,
            startupId: buy.startup_id,
            tokenSymbol: buy.token_symbol,
            avgPrince: price,
          },
        ];
    tx.update(walletRefBuyer, { holdings: updatedBuyerHoldings });

    // executeOrderExecution
    const buyFilled = (buyOrderSnap.data()?.quantity_filled ?? 0) + qty;
    const buyStatus = buyFilled >= buy.quantity ? "filled" : "partially";
    tx.update(buyOrderRef, { quantity_filled: buyFilled, status: buyStatus });

    const sellFilled = (sellOrderSnap.data()?.quantity_filled ?? 0) + qty;
    const sellStatus = sellFilled >= sell.quantity ? "filled" : "partially";
    tx.update(sellOrderRef, {
      quantity_filled: sellFilled,
      status: sellStatus,
    });

    // createTrade
    const tradeRef = db.collection("trades").doc();
    tx.set(tradeRef, {
      buyOrderId: buy.id,
      sellOrderId: sell.id,
      startupId: buy.startup_id,
      buyerId: buy.user_id,
      sellerId: sell.user_id,
      qty,
      price,
      totalValue,
      executedAt: new Date(),
    });

    const buyTransaction = {
      amountBRL: totalValue,
      createdAt: Timestamp.now(),
      description: `Compra de \$${buy.token_symbol}`,
      tradeId: tradeRef.id,
      type: "expense",
      userId: buy.user_id,
    } as TransactionModel;

    const buyTransactionRef = db.collection("transactions").doc();
    tx.create(buyTransactionRef, buyTransaction);

    const sellTransaction = {
      amountBRL: totalValue,
      createdAt: Timestamp.now(),
      description: `Venda de \$${sell.token_symbol}`,
      tradeId: tradeRef.id,
      type: "income",
      userId: sell.user_id,
    } as TransactionModel;

    const sellTransactionRef = db.collection("transactions").doc();
    tx.create(sellTransactionRef, sellTransaction);

    //addPriceToPriceHistory
    const priceHistoryRef = db
      .collection("startups")
      .doc(buy.startup_id)
      .collection("price_history")
      .doc();
    const newPriceHistoryEntry: StartupPriceHistory = {
      price: buy.price,
      quantity: qty,
      executed_at: Timestamp.now(),
    };
    tx.set(priceHistoryRef, newPriceHistoryEntry);
  });
}
