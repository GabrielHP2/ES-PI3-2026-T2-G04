// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";
import { onRequest } from "firebase-functions/https";  
import { logger } from "firebase-functions";

const db = getFirestore();

export const testWalletTransactions = onRequest(async (request, response) => {

    try {

        const userId = "teste";

        const snapshot = await db.collection("transactions")
        .where("userId", "==", userId)
        .get();

        if (snapshot.empty) {

            logger.info("Info from walletBalance: Nenhuma transação registrada");
        }

        const transactions = []; 

        for (const doc of snapshot.docs) {

            transactions.push(doc.data());
        }

        response.status(200).json(transactions);

    } catch (err) {

        response.status(500).json({error: "Falha ao pegar a Transaction: ", err});
        return;
    }
});