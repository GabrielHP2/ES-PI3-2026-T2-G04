import { Order } from "../../orders/types/orderType";

export interface MatchesExecuted {
  matchesExecuted: number;
}

export interface MatchOrder {
  buy: Order;
  sell: Order;
}
