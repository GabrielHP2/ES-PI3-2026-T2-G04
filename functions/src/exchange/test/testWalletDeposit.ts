// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";
import { onRequest } from "firebase-functions/https";  
import { logger } from "firebase-functions";

import { PaymentType, WalletType } from "../types/walletType";
import { getBalance } from "../repositories/getBalance";
import { makeTransaction } from "../repositories/makeTransaction";

const db = getFirestore();

export const testWalletDeposit = onRequest(async (request, response) => {
    
    try {

        const { depositQuantity, paymentMethod } = request.body as {depositQuantity: number, paymentMethod: PaymentType};
        
        // Verifica se a quantidade de depósito foi fornecida
        if (!depositQuantity) {
            
            logger.error("Error from walletDeposit: Falha ao obter quantidade de depósito");
            response.status(400).json({error: "not-found, Falha ao obter quantidade de depósito"});
            return;
        }
    
        // Verifica se a forma de pagamento foi fornecida
        if (!paymentMethod) {
            
            logger.error("Error from walletDeposit: Forma de pagamento não especificada");
            response.status(400).json({error: "not-found, Forma de pagamento não especificada"});
            return;
        }
        
        // Verifica se a quantidade de depósito é válida
        if (depositQuantity < 1) {
            
            logger.error("Error from walletDeposit: Valor de depósito inválido");
            response.status(400).json({error: "invalid-argument, Valor de depósito inválido"});
            return;
        }
    
        const userId = "teste";
    
        // Pega a referência da carteira do usuário no BD
        const walletRef = db.collection("wallets").doc(userId);
        const snapshot = await walletRef.get();

        // Verifica se a carteira do usuário existe, caso contrário, cria uma nova carteira com saldo zero
        if (!snapshot.exists) {

            await walletRef.set({ availableBalance: 0, blockedBalance: 0 });
        }

        // Pega o saldo atual do usuário no BD
        const balances = await getBalance(userId) as WalletType;
        const currentBalance = balances.availableBalance;
    
        // Calcula o novo saldo somando a quantidade de depósito ao saldo atual
        const newBalance = currentBalance + depositQuantity;
    
        // Atualiza o saldo disponível do usuário no banco de dados
        await db.collection("wallets")
        .doc(userId)
        .set({availableBalance: newBalance}, {merge: true});
        
        // Registra a transação de depósito no banco de dados e obtém os detalhes da transação criada
        const transaction = await makeTransaction(
            userId, 
            "income", 
            depositQuantity, 
            paymentMethod, 
        );
        
        response.status(200).json({newBalance, transaction});

    } catch (err) {
        logger.error("Error from walletDeposit: Falha ao fazer o depósito", err);
        response.status(500).json({error: "Falha ao fazer o depósito"});
        return;
    }
});