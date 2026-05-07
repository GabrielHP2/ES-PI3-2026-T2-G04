// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";

import { WalletType } from "../types/walletType";

const db = getFirestore();

// Busca no BD o saldo disponível ou bloqueado do usuário
export async function getBalance(userId: string): Promise<WalletType> {

    return await db.collection("wallets")
    .doc(userId)       
    .get()
    .then((snapshot) => {
        
        const data = snapshot.data() as WalletType; 
        
        // Retorna os saldos disponível e bloqueado do usuário 
        return data;
    });
}