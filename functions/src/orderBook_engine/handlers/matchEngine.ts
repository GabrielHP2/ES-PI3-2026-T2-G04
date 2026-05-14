import { HttpsError } from "firebase-functions/https";
import { getOrdersByStartup } from "../../orders/repositories/ordersRepositories";
import { Order, OrderStatus, OrderType } from "../../orders/types/orderType";
import { MatchesExecuted, MatchOrder } from "../types/matchTypes";
import { db } from "../../startups/shared/firebase";
import {
  TokenWalletType,
  TransactionModel,
} from "../../exchange/types/walletType";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { StartupPriceHistory } from "../../startups/types/startupType";
import {
  toDecimal,
  multiply,
  add,
  subtract,
  isGreaterThanOrEqual,
  isLessThan,
  toString,
} from "../../shared/decimalUtils";

export async function matchOrders(startupId: string): Promise<MatchesExecuted> {
  const startupOrders: Order[] = await getOrdersByStartup(startupId);
  let startupOpenOrders: Order[] = [];
  startupOrders.map((o) => {
    if (o.status === OrderStatus.open || o.status === OrderStatus.partially) {
      startupOpenOrders.push(o);
    }
  });

  if (startupOpenOrders.length == 0) return { matchesExecuted: 0 };
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
      const wasExecuted = await settleMatch(mo.buy, mo.sell);
      if (wasExecuted) {
        matchesExecutedCount++;
      }
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
  buys.sort((a, b) => {
    const priceDiff = toDecimal(b.price).minus(toDecimal(a.price));
    if (!priceDiff.isZero()) {
      return priceDiff.isPositive() ? 1 : -1;
    }
    return a.createdAt.toMillis() - b.createdAt.toMillis();
  });
  sells.sort((a, b) => {
    const priceDiff = toDecimal(a.price).minus(toDecimal(b.price));
    if (!priceDiff.isZero()) {
      return priceDiff.isPositive() ? 1 : -1;
    }
    return a.createdAt.toMillis() - b.createdAt.toMillis();
  });
  let matchingOrders: MatchOrder[] = [];
  for (let i: number = 0; i < buys.length; i++) {
    for (let j: number = 0; j < sells.length; j++) {
      if (
        isGreaterThanOrEqual(
          toDecimal(buys[i].price),
          toDecimal(sells[j].price),
        )
      ) {
        if (buys[i].user_id === sells[j].user_id) {
          continue;
        }
        matchingOrders.push({ buy: buys[i], sell: sells[j] } as MatchOrder);
      }
    }
  }
  return matchingOrders;
}

async function settleMatch(buy: Order, sell: Order): Promise<boolean> {
  return db.runTransaction(async (tx) => {
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
    const currentBuyOrder = buyOrderSnap.data() as Order | undefined;
    const currentSellOrder = sellOrderSnap.data() as Order | undefined;

    if (!currentBuyOrder || !currentSellOrder) {
      return false;
    }

    if (
      (currentBuyOrder.status !== OrderStatus.open &&
        currentBuyOrder.status !== OrderStatus.partially) ||
      (currentSellOrder.status !== OrderStatus.open &&
        currentSellOrder.status !== OrderStatus.partially)
    ) {
      return false;
    }

    if (currentBuyOrder.user_id === currentSellOrder.user_id) {
      return false;
    }

    if (
      isLessThan(
        toDecimal(currentBuyOrder.price),
        toDecimal(currentSellOrder.price),
      )
    ) {
      return false;
    }

    const remainingBuy =
      currentBuyOrder.quantity - currentBuyOrder.quantity_filled;
    const remainingSell =
      currentSellOrder.quantity - currentSellOrder.quantity_filled;
    const qty = Math.min(remainingBuy, remainingSell);

    if (qty <= 0) {
      return false;
    }

    const price = toDecimal(currentSellOrder.price);
    const totalValue = multiply(price, qty);

    // Validações de consistência
    const sellerHolding = sellerWallet.holdings.find(
      (h) => h.startup_id === currentSellOrder.startup_id,
    );

    console.log("[settleMatch] DEBUG", {
      sellStartup_id: currentSellOrder.startup_id,
      sellerHoldings: JSON.stringify(sellerWallet.holdings),
    });
    if (!sellerHolding || sellerHolding.blocked_token_balance < qty) {
      console.error(
        "[settleMatch] Inconsistência: blockedTokenBalance insuficiente",
        {
          sellOrderId: sell.id,
          buyOrderId: buy.id,
          expected: qty,
          found: sellerHolding?.blocked_token_balance ?? 0,
        },
      );
      return false;
    }
    if (isLessThan(toDecimal(buyerWallet.blockedBalance), totalValue)) {
      console.error(
        "[settleMatch] Inconsistência: blockedBalance insuficiente",
        {
          buyOrderId: buy.id,
          expected: toString(totalValue),
          found: buyerWallet.blockedBalance,
        },
      );
      return false;
    }

    // transferFunds
    const newBuyerBlockedBalance = subtract(
      toDecimal(buyerWallet.blockedBalance),
      totalValue,
    );
    tx.update(walletRefBuyer, {
      blockedBalance: toString(newBuyerBlockedBalance),
    });
    const newSellerAvailableBalance = add(
      toDecimal(sellerWallet.availableBalance),
      totalValue,
    );
    tx.update(walletRefSeller, {
      availableBalance: toString(newSellerAvailableBalance),
    });

    // transferTokens
    const updatedSellerHoldings = sellerWallet.holdings.map((h) =>
      h.startup_id === currentSellOrder.startup_id
        ? {
            ...h,
            blocked_token_balance: h.blocked_token_balance - qty,
            avg_price: h.avg_price,
          }
        : h,
    );
    tx.update(walletRefSeller, { holdings: updatedSellerHoldings });

    const buyerHoldings = buyerWallet.holdings || [];

    const buyerHoldingExists = buyerHoldings.some(
      (h) => h.startup_id === currentBuyOrder.startup_id,
    );

    const priceDecimal = toDecimal(currentSellOrder.price);
    const updatedBuyerHoldings = buyerHoldingExists
      ? buyerHoldings.map((h) =>
          h.startup_id === currentBuyOrder.startup_id
            ? {
                ...h,
                token_balance: h.token_balance + qty,
                avg_price: toString(
                  add(
                    multiply(
                      toDecimal(h.token_balance),
                      h.avg_price ? toDecimal(h.avg_price) : priceDecimal,
                    ),
                    multiply(qty, priceDecimal),
                  ).dividedBy(h.token_balance + qty),
                ),
              }
            : h,
        )
      : [
          ...buyerHoldings,
          {
            token_balance: qty,
            blocked_token_balance: 0,
            startup_id: currentBuyOrder.startup_id,
            token_symbol: currentBuyOrder.token_symbol,
            avg_price: toString(priceDecimal),
          },
        ];

    tx.update(walletRefBuyer, { holdings: updatedBuyerHoldings });

    // executeOrderExecution
    const buyFilled = currentBuyOrder.quantity_filled + qty;
    const buyStatus =
      buyFilled >= currentBuyOrder.quantity ? "filled" : "partially";
    tx.update(buyOrderRef, { quantity_filled: buyFilled, status: buyStatus });

    const sellFilled = currentSellOrder.quantity_filled + qty;
    const sellStatus =
      sellFilled >= currentSellOrder.quantity ? "filled" : "partially";
    tx.update(sellOrderRef, {
      quantity_filled: sellFilled,
      status: sellStatus,
    });

    // createTrade
    const tradeRef = db.collection("trades").doc();
    tx.set(tradeRef, {
      buyOrderId: buy.id,
      sellOrderId: sell.id,
      startup_id: currentBuyOrder.startup_id,
      buyerId: currentBuyOrder.user_id,
      sellerId: currentSellOrder.user_id,
      qty,
      price: toString(price),
      totalValue: toString(totalValue),
      executedAt: new Date(),
    });

    const buyTransaction = {
      amountBRL: toString(totalValue),
      createdAt: Timestamp.now(),
      description: `Compra de \$${currentBuyOrder.token_symbol}`,
      tradeId: tradeRef.id,
      type: "expense",
      userId: currentBuyOrder.user_id,
    } as TransactionModel;

    const buyTransactionRef = db.collection("transactions").doc();
    tx.create(buyTransactionRef, buyTransaction);

    const sellTransaction = {
      amountBRL: toString(totalValue),
      createdAt: Timestamp.now(),
      description: `Venda de \$${currentSellOrder.token_symbol}`,
      tradeId: tradeRef.id,
      type: "income",
      userId: currentSellOrder.user_id,
    } as TransactionModel;

    const sellTransactionRef = db.collection("transactions").doc();
    tx.create(sellTransactionRef, sellTransaction);

    // updateStartupLastPrice
    const startupRef = db
      .collection("startups")
      .doc(currentBuyOrder.startup_id);
    tx.set(
      startupRef,
      {
        last_price: toString(price),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    //addPriceToPriceHistory
    const priceHistoryRef = db
      .collection("startups")
      .doc(currentBuyOrder.startup_id)
      .collection("price_history")
      .doc();
    const newPriceHistoryEntry: StartupPriceHistory = {
      price: toString(price),
      quantity: qty,
      executed_at: Timestamp.now(),
    };
    tx.set(priceHistoryRef, newPriceHistoryEntry);

    return true;
  });
}
