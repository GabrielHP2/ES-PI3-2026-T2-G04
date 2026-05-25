// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { Timestamp } from "firebase-admin/firestore";

export type TransactionType = "expense" | "income";

export type BalanceType = "available" | "blocked" | "both";

export type PaymentType = "credit" | "debit" | "pix" | "none";

export interface TransactionModel {
  amountBRL: string; // Armazenado como string para precisão
  createdAt: Timestamp;
  description: string;
  tradeId?: string;
  type: TransactionType;
  userId: string;
}

// Type igual ao TransactionModel, mas sem o campo createdAt e com o campo tradeId opcional
export type TransactionData = TransactionModel & { tradeId?: string };

export interface WalletType {
  availableBalance: string; // Armazenado como string para precisão
  blockedBalance: string; // Armazenado como string para precisão
}

export interface TokenWalletType {
  availableBalance: string; // Armazenado como string para precisão
  blockedBalance: string; // Armazenado como string para precisão
  holdings: Holding[];
}

type Holding = {
  startup_id: string;
  token_symbol: string;
  token_balance: number;
  blocked_token_balance: number;
  avg_price: string; // Armazenado como string para precisão
};
