// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";  
import { logger } from "firebase-functions";


const db = getFirestore();

export const walletTransaction = onCall(async (request) => {

    // Decodifica o token do usuário e verifica se ele tem um id válido
    if (!request.auth) {

        logger.error("Error from walletTransaction: Usuário não autenticado");
        throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }

    // Consulta as transações do usuário no banco de dados
    const snapshot = await db.collection("transactions")
    .where("userId", "==", request.auth.uid)  
    .get();

    // Verifica se o usuário tem alguma transação
    if (snapshot.empty) {

        logger.info("Info from walletTransaction: Nenhuma transação registrada");
        throw new HttpsError("unauthenticated", "Nenhuma transação registrada");
    }

    const transactions = []; 

    for (const doc of snapshot.docs) {

        transactions.push(doc.data());
    }

    logger.info("Info from walletTransaction: OK");

    return transactions;
});