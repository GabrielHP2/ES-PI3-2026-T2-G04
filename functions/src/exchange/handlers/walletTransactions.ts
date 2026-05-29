// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { logger } from "firebase-functions";
import { TransactionModel } from "../types/walletType";
import { db } from "../../shared/firebase";

export const walletTransaction = onCall(async (request) => {
  // Decodifica o token do usuário e verifica se ele tem um id válido
  if (!request.auth) {
    logger.error("Error from walletTransaction: Usuário não autenticado");
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }
  try {
    const snapshot = await db
      .collection("transactions")
      .where("userId", "==", request.auth.uid)
      .orderBy("createdAt", "desc")
      .get();

    if (snapshot.empty) {
      logger.info("Info from walletTransaction: Nenhuma transação registrada");
      return [];
    }

    // AGORA USANDO A INTERFACE NO MAP
    const transactions = snapshot.docs.map((doc) => {
      const data = doc.data();

      const transaction: TransactionModel = {
        amountBRL: data.amountBRL,
        description: data.description,
        tradeId: data.tradeId,
        type: data.type,
        userId: data.userId,
        // Garantia total contra o erro de 'Null' que você teve no Flutter
        createdAt:
          data.createdAt instanceof Timestamp
            ? data.createdAt
            : Timestamp.now(),
      };

      return transaction;
    });

    logger.info("Info from walletTransaction: OK");
    return transactions;
  } catch (error) {
    logger.error("Error from walletTransaction:", error);
    throw new HttpsError("internal", "Erro interno ao buscar transações");
  }
});
