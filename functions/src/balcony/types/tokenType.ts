import { Timestamp } from "firebase-admin/firestore";

export interface PriceHistoryResponseItem {
  id: string;
  price: string; // Armazenado como string para precisão
  quantity: number | null;
  executed_at: Timestamp;
}

export interface TokenResponse {
  id: string;
  name: string;
  token_symbol: string;
  last_price: string; // Armazenado como string para precisão
  current_raised: string; // Armazenado como string para precisão
  price_history: PriceHistoryResponseItem[];
}
