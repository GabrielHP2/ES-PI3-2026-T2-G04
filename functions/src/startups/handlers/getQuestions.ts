// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { onCall, HttpsError } from "firebase-functions/https";
import { db } from "../shared/firebase";
import * as logger from "firebase-functions/logger";

import { MessageType } from "../types/messageType";

export const getQuestions = onCall(async (request) => {

    // Decodifica o token do usuário e verifica se ele tem um id válido
    if (!request.auth) {

        logger.error("Error from getQuestions: Usuário não autenticado");
        throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }

    // Pega no corpo da requisição o ID da startup e a visibilidade das perguntas
    const { startupId, visibility } = request.data as {startupId: string, visibility: boolean};

    if (!startupId || !visibility) {

        logger.error("Error from getQuestions: Falha ao identificar a startup");
        throw new HttpsError("not-found", "Falha ao identificar a startup");
    }

    let messages: MessageType[] = [];

    // Busca as perguntas da startup no BD
    await db.collection("questions")
    .doc(startupId)
    .get()
    .then((snapshot) => {

        if (!snapshot.exists) {

            logger.error("Error from getQuestions: Falha ao buscar as perguntas");
            throw new HttpsError("data-loss", "Falha ao buscar as perguntas");
        }

        const data = snapshot.data();

        // Dependendo da visibilidade, retorna as perguntas públicas ou privadas
        messages = visibility ? data!.public : data!.private;

        logger.info("Info from getQuestions: OK");

        return messages;

    }).catch((err) => {

        logger.error(`Error from getQuestions: Falha ao buscar as perguntas - ${err}`);
        throw new HttpsError("data-loss", `Falha ao buscar as perguntas - ${err}`);
    });
});
