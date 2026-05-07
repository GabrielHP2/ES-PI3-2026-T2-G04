// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";
import { onRequest } from "firebase-functions/https";  
import { logger } from "firebase-functions";

import { getBalance } from "../repositories/getBalance";

const db = getFirestore();

export const testWalletBalance = onRequest(async (request, response) => {

    try {
        
        const userId = "teste";

        // Pega a referência da carteira do usuário no BD
        const walletRef = db.collection("wallets").doc(userId);
        const snapshot = await walletRef.get();

        // Verifica se a carteira do usuário existe, caso contrário, cria uma nova carteira com saldo zero
        if (!snapshot.exists) {

            await walletRef.set({ availableBalance: 0, blockedBalance: 0 });
        }
    
        const result = await getBalance(userId);
        logger.debug("Debug from testBalance: ", result);
        response.status(200).json(result);
        return;
        
    } catch (err) {

        response.status(500).json({error: "Falha ao fazer o testBalance: ", err});
        return;
    }

});