import { HttpsError } from "firebase-functions/https";
import { getOrdersByStartup } from "../../orders/repositories/ordersRepositories";
import { Order, OrderStatus, OrderType } from "../../orders/types/orderType";
import { MatchesExecuted, MatchOrder } from "../types/matchTypes";
import { db } from "../../startups/shared/firebase";
import { TokenWalletType } from "../../exchange/types/walletType";

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
      const { minQty, price } = resolveMatch(mo.buy, mo.sell);
      await settleMatch(mo.buy, mo.sell, minQty, price);
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

  const minQty = Math.min(remainingBuy, remainingSell);

  const price = sell.price;
  return { minQty, price };
}

async function settleMatch(
  buy: Order,
  sell: Order,
  minQty: number,
  price: number,
) {
  await db.runTransaction(async (tx) => {
    const walletRefBuyer = db.collection("wallets").doc(buy.user_id!);
    const buyerWalletSnap = await tx.get(walletRefBuyer);
    const walletRefSeller = db.collection("wallets").doc(sell.user_id!);
    const sellerWalletSnap = await tx.get(walletRefSeller);

    const buyOrderRef = db.collection("orders").doc(buy.id);
    const sellOrderRef = db.collection("orders").doc(sell.id);

    const buyerWallet: TokenWalletType =
      buyerWalletSnap.data()! as TokenWalletType;
    const sellerWallet: TokenWalletType =
      sellerWalletSnap.data()! as TokenWalletType;

    const totalValue = minQty * price;

    const sellerHolding = sellerWallet.holdings.find(
      (h) => h.startupId === sell.startup_id,
    );

    if (!sellerHolding || sellerHolding.blockedTokenBalance < minQty) {
      console.error(
        `[settleMatch] Inconsistência: vendedor ${sell.user_id} não tem blocked_token_balance suficiente.`,
        {
          sellOrderId: sell.id,
          buyOrderId: buy.id,
          expected: minQty,
          found: sellerHolding?.blockedTokenBalance ?? 0,
        },
      );
      return; // pula o par, tx não commita nada
    }

    if (buyerWallet.blockedBalance < totalValue) {
      console.error(
        `[settleMatch] Inconsistência: comprador ${buy.user_id} não tem blockedBalance suficiente.`,
        {
          buyOrderId: buy.id,
          expected: totalValue,
          found: buyerWallet.blockedBalance,
        },
      );
      return;
    }

    //transferFunds()
    //transferTokens()
    //executeOrderExecution() * 2 (buy e sell)
    //createTrade()
  });
}
