import {Timestamp} from "firebase-admin/firestore";

export enum OrderStatus {
  open, partially, filled, cancelled
}

export enum OrderType {
  buy, sell
}

export interface Order {
  id: string;
  price: number;
  quantity: number;
  quantity_filled: number;
  startup_id: string;
  status: OrderStatus;
  token_symbol: string;
  type: OrderType;
  user_id: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export type CreateOrderDTO = Omit<Order, "id">;
