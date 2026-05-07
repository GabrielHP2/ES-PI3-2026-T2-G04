// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import {getFirestore} from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";  
import { logger } from "firebase-functions";

import { getBalance } from "../repositories/getBalance";

const db = getFirestore();

export const walletBalance = onCall(async (request) => {

    // Decodifica o token do usuário e verifica se ele tem um id válido
    if (!request.auth) {

        logger.error("Error from walletBalance: Usuário não autenticado");
        throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }

    // Pega a referência da carteira do usuário no BD
    const walletRef = db.collection("wallets").doc(request.auth.uid);
    const snapshot = await walletRef.get();

    // Verifica se a carteira do usuário existe, caso contrário, cria uma nova carteira com saldo zero
    if (!snapshot.exists) {

        await walletRef.set({ availableBalance: 0, blockedBalance: 0 });
    }

    // Retorna os saldos disponível e bloqueado do usuário 
    return await getBalance(request.auth.uid);
});