// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { Timestamp } from "firebase-admin/firestore";

export type TransactionType = "expense" | "income";

export type BalanceType = "available" | "blocked" | "both";

export type PaymentType = "credit" | "debit" | "pix" | "none";

export interface TransactionModel {
  amountBRL: number;
  createdAt: Timestamp;
  description: string;
  tradeId?: string;
  type: TransactionType;
  userId: string;
}

// Type igual ao TransactionModel, mas sem o campo createdAt e com o campo tradeId opcional
export type TransactionData = TransactionModel & { tradeId?: string };

export interface WalletType {
  availableBalance: number;
  blockedBalance: number;
}

export interface TokenWalletType {
  availableBalance: number;
  blockedBalance: number;
  holdings: Holding[];
}

export interface Holding {
  tokenBalance: number;
  blockedTokenBalance: number;
  startupId: string;
  tokenSymbol: string;
  avgPrice: number;
}
