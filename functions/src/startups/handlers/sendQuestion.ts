// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import {onCall, HttpsError} from "firebase-functions/https";
import {db} from "../shared/firebase";
import {Timestamp} from "firebase-admin/firestore";
import {isInvestor} from "../repositories/isInvestor";
import {Question} from "../types/questionType";

export const sendQuestion = onCall(async (request) => {
  if (!request || !request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  // Espera-se que o cliente envie apenas: is_public, question_text, startup_id
  const body = (request.data as unknown) as Partial<Question>;
  if (!body || !body.startup_id || typeof body.question_text !== "string") {
    throw new HttpsError("invalid-argument", "Conteúdo da pergunta incompleto: envie 'startup_id' e 'question_text'");
  }

  // Preenche user_id a partir do auth e aplica valores padrão
  const userId = request.auth.uid;
  const toSave = {
    startup_id: body.startup_id,
    user_id: userId,
    is_public: !!body.is_public,
    question_text: body.question_text,
    created_at: Timestamp.now(),
    is_answered: false,
    status: "active",
  };

  try {
    // Se for privada, valida se o usuário é investidor
    if (!toSave.is_public) {
      const ok = await isInvestor(userId, toSave.startup_id);
      if (!ok) {
        throw new HttpsError("permission-denied", "O usuário deve ser um investidor para enviar perguntas privadas");
      }
    }

    // Adiciona cada pergunta como um documento separado na coleção `questions`.
    const ref = await db.collection("questions").add(toSave);

    return {id: ref.id};
  } catch (err) {
    throw new HttpsError("data-loss", "Falha ao cadastrar a pergunta - " + err);
  }
});
