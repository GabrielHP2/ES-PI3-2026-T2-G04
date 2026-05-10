import {Timestamp} from "firebase-admin/firestore";

export interface PriceHistoryResponseItem {
  id: string;
  price: number;
  quantity: number | null;
  executed_at: Timestamp;
}

export interface TokenResponse {
  id: string;
  name: string;
  token_symbol: string;
  last_price: number;
  current_raised: number;
  price_history: PriceHistoryResponseItem[];
}
