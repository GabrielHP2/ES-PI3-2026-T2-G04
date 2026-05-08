import { HttpsError } from "firebase-functions/https";
import { getOrdersByStartup } from "../../orders/repositories/ordersRepositories";
import { Order, OrderStatus, OrderType } from "../../orders/types/orderType";
import { MatchesExecuted, MatchOrder } from "../types/matchTypes";

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
  matchingOrders.map((mo) => {
    //resolveMatch()
    //settleMatch()
    //Se functionar tudo certinho
    matchesExecutedCount++;
  });

  return { matchesExecuted: matchesExecutedCount };
}

function findMatchingOrders(buys: Order[], sells: Order[]): MatchOrder[] {
  if (buys.length == 0 || sells.length == 0) {
    return [];
  }
  buys.sort((a, b) =>
    b.price - a.price == 0
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
