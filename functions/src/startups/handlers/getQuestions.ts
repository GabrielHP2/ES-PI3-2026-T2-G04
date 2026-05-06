// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import {onCall, HttpsError} from "firebase-functions/https";
import {db} from "../shared/firebase";

//  import {MessageType} from "../types/messageType";
//  import {Question} from "../types/questionType";

export const getQuestions = onCall(async (request) => {
  // Verifica autenticação
  if (!request || !request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const {startupId, isPublic} = request as any;
  if (!startupId) {
    throw new HttpsError("not-found", "Falha ao identificar a startup");
  }

  try {
    const snapshot = await db.collection("questions")
      .where("startupId", "==", startupId)
      .where("is_public", "==", isPublic)
      .get();

    const questions = snapshot.docs
      .map((doc) => (
        {id: doc.id, ...(doc.data())}));
    return questions;
  } catch (err) {
    throw new HttpsError("data-loss", "Falha ao buscar as perguntas - " + err);
  }
});
