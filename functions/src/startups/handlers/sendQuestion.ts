// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { onCall, HttpsError } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { FieldValue } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

import { MessageType } from "../types/messageType";
import { isInvestor } from "../repositories/isInvestor";

export const sendQuestion = onCall(async (request) => {

    
    if (!request.auth) {
    
        logger.error("Error from sendQuestion: Usuário não autenticado");
        throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }

    const messageBody = request.data as MessageType;

    if (!messageBody) {
    
        logger.error("Error from sendQuestion: Conteúdo da pergunta não encontrado");
        throw new HttpsError("not-found", "Conteúdo da pergunta não encontrado");
    }

    // Verifica se a pergunta é privada
    if (!messageBody.isPublic) {
        
        // Caso seja privada, verifica se o usuário é um investidor da startup
        if (!await isInvestor(messageBody.question.userId, messageBody.startupId)) {

            logger.error("Error from sendQuestion: O usuário deve ser um investidor");
            throw new HttpsError("permission-denied", "O usuário deve ser um investidor");
        }
        
        // Cadastra a pergunta privada no BD no array "private"
        await db.collection("questions")
        .doc(messageBody.startupId)
        .set({private: FieldValue.arrayUnion(messageBody)}, {merge: true});

        logger.debug("Debug from sendQuestion: Pergunta privada cadastrada");
    }
    
    else {
        
        // Cadastra a pergunta pública no BD no array "public" 
        await db.collection("questions")
        .doc(messageBody.startupId)
        .set({public: FieldValue.arrayUnion(messageBody)}, {merge: true});

        logger.debug("Debug from sendQuestion: Pergunta pública cadastrada");
    }
    
    logger.info("Info from sendQuestion: OK");

    return;
});
