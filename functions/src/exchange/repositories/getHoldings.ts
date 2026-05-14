// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";

import { TokenWalletType } from "../types/walletType";

const db = getFirestore();

// Busca no BD o saldo disponível ou bloqueado do usuário
export async function getHoldings(userId: string): Promise<TokenWalletType> {
  return await db
    .collection("wallets")
    .doc(userId)
    .get()
    .then((snapshot) => {
      logger.info("getHoldings: snapshot lido do Firestore", {
        userId,
        exists: snapshot.exists,
        data: snapshot.exists ? snapshot.data() : null,
      });

      if (snapshot.exists) {
        const result = snapshot.data()!;
        const data: TokenWalletType = {
          availableBalance: result.availableBalance ?? "0.00",
          blockedBalance: result.blockedBalance ?? "0.00",
          holdings: result.holdings ?? result.Holdings ?? [],
        };

        logger.info("getHoldings: payload normalizado", {
          userId,
          data,
        });

        return data;
      }

      logger.info("getHoldings: carteira inexistente, retornando padrão", {
        userId,
      });

      return {
        availableBalance: "0.00",
        blockedBalance: "0.00",
        holdings: [],
      } as TokenWalletType;
    });
}
