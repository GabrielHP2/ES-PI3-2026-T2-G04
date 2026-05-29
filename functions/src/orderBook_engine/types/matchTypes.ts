// João Pedro Panza Mainieri - 25006642;
import { Order } from "../../orders/types/orderType";

export interface MatchesExecuted {
  matchesExecuted: number;
}

export interface MatchOrder {
  buy: Order;
  sell: Order;
}
