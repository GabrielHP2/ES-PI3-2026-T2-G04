// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";  
import { logger } from "firebase-functions";

import {makeTransaction} from "../repositories/makeTransaction";
import {getBalance} from "../repositories/getBalance";
import { WalletType } from "../types/walletType";

const db = getFirestore();

export const walletWithdraw = onCall(async (request) => {

    // Decodifica o token do usuário e verifica se ele tem um id válido
    if (!request.auth) {

        logger.error("Error from walletWithdraw: Usuário não autenticado");
        throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }
    
    const { withdrawQuantity } = request.data;
    
    // Verifica se a quantidade de saque foi fornecida
    if (!withdrawQuantity) {
        
        logger.error("Error from walletWithdraw: Falha ao obter quantidade de saque");
        throw new HttpsError("not-found", "Falha ao obter quantidade de saque");
    }
    
    const userId = request.auth.uid;

    // Pega a referência da carteira do usuário no BD
    const walletRef = db.collection("wallets").doc(userId);
    const snapshot = await walletRef.get();

    // Verifica se a carteira do usuário existe, caso contrário, cria uma nova carteira com saldo zero
    if (!snapshot.exists) {

        await walletRef.set({ availableBalance: 0, blockedBalance: 0 }); 
    }

    // Pega o saldo disponível do usuário no BD
    const balances = await getBalance(userId) as WalletType;
    const currentBalance = balances.availableBalance;
    
    // Verifica se a quantidade de saque é válida
    if (withdrawQuantity < 1 || withdrawQuantity > currentBalance) {

        logger.error("Error from walletWithdraw: Valor de saque inválido");
        throw new HttpsError("invalid-argument", "Valor de saque inválido");
    }

    // Calcula o novo saldo subtraindo a quantidade de saque do saldo atual
    const newBalance = currentBalance - withdrawQuantity;
    
    // Atualiza o saldo disponível do usuário no banco de dados
    await db.collection("wallets")
    .doc(userId)
    .set({availableBalance: newBalance}, {merge: true}); 
    
    // Registra a transação de saque no banco de dados e obtém os detalhes da transação criada
    const transaction = await makeTransaction(
        userId, 
        "expense", 
        withdrawQuantity,
    );
    
    return {newBalance, transaction};
});