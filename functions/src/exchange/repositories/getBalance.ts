// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";

import { WalletType } from "../types/walletType";

const db = getFirestore();

// Busca no BD o saldo disponível ou bloqueado do usuário
export async function getBalance(userId: string): Promise<WalletType> {
  return await db
    .collection("wallets")
    .doc(userId)
    .get()
    .then((snapshot) => {
      if (snapshot.exists) {
        const { availableBalance, blockedBalance } = snapshot.data()!;
        const data: WalletType = {
          availableBalance:
            typeof availableBalance === "string"
              ? availableBalance
              : availableBalance.toString(),
          blockedBalance:
            typeof blockedBalance === "string"
              ? blockedBalance
              : blockedBalance.toString(),
        } as WalletType;
        return data;
      }
      return { availableBalance: "0.00", blockedBalance: "0.00" } as WalletType;
    });
}
