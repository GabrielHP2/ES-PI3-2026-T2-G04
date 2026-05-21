// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { Timestamp } from "firebase-admin/firestore";

export interface TradeType {

    buyOrderId: string;
    buyerId: string;
    executedAt: Timestamp;
    price: string;
    qty: number;
    sellOrderId: string;
    sellerId: string;
    startup_id: string;
    totalValue: string;
}