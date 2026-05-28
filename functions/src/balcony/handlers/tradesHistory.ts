//Lucas Leonel - RA: 25015188
//Joao Pedro Maineri - RA: 25006642
// Gabriel Henrique Pacagnelli Pagliato - RA: 25016528

import { Filter, getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getTokenSymbols } from "../repositories/getTokenSymbols";
import { TradeType } from "../types/tradeType";

const db = getFirestore();

export const tradesHistory = onCall(async (request) => {
  if (!request.auth) {
    logger.error("Error from tradesHistory: User not authenticated");
    throw new HttpsError("unauthenticated", "User not authenticated.");
  }

  try {

    // Faz um query no BD usando filter pra pegar as trades 
    // onde o buyerId ou sellerId seja igual ao id do usuário
    const tradesSnapshot = await db.collection("trades")
    .where(Filter.or
      (
        Filter.where("buyerId", "==", request.auth.uid), 
        Filter.where("sellerId", "==", request.auth.uid)
      )
    )
    .orderBy("executedAt", "desc")
    .get();

    if (tradesSnapshot.empty) {
      logger.info("Nenhuma trade encontrada");
      return { tradesWithSymbols: [] };
    }

    // Cria um array de trades a partir do snapshot
    const trades = tradesSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data() as TradeType,
    }));

    // Pega os símbolos dos tokens das trades usando a função getTokenSymbols
    const symbolsList = await getTokenSymbols(trades);

    // Adiciona o símbolo de cada token em cada trade
    const tradesWithSymbols = trades.map((element) => {
      
      const token_symbol = symbolsList[element.startup_id];
      return {
        ...element,
        token_symbol,
      };
    });

    logger.info(`tradesHistory: ${trades.length}`);
    return { tradesWithSymbols };
  } catch (error) {
    logger.error("Error from tradesHistory: ", error);
    throw new HttpsError("internal", "Failed to fetch trades history.");
  }
});
