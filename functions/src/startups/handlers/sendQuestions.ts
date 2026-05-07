// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { createQuestion } from "../repositories/questionsRepositories";
import { isInvestor } from "../repositories/isInvestor";
import { getUserNameById } from "../../auth/repositories/userRepositories";
import { CreateQuestionDTO } from "../types/questionType";

/**
 * Sends a question to a startup in the system.
 *
 * Expected request.data structure:
 * {
 *   question_text: string,    // Texto da pergunta
 *   startup_id: string,       // ID da startup
 *   is_public: boolean        // Se a pergunta é pública
 * }
 *
 * Returns: { questionId: string, message: string }
 */
export const sendQuestions = onCall(async (request) => {
  // Verifica autenticação
  if (!request || !request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const question = request.data as Omit<
    CreateQuestionDTO,
    "is_answered" | "created_at" | "status" | "user_id"
  >;

  if (!question || !question.startup_id || !question.question_text) {
    throw new HttpsError(
      "invalid-argument",
      "Informe uma pergunta válida com 'startup_id' e 'question_text'",
    );
  }

  const userId = request.auth.uid;

  // Puxar o nome do usuário
  let userName: string;
  try {
    userName = await getUserNameById(userId);
  } catch (err) {
    throw new HttpsError("not-found", "Falha ao identificar o nome do usuário");
  }

  // Se for privada, valida se o usuário é investidor
  if (!question.is_public) {
    const ok = await isInvestor(userId, question.startup_id);
    if (!ok) {
      throw new HttpsError(
        "permission-denied",
        "O usuário deve ser um investidor para enviar perguntas privadas",
      );
    }
  }

  const docRef = await createQuestion(
    question.startup_id,
    userId,
    userName,
    question.question_text,
    question.is_public || false,
  );

  return {
    questionId: docRef.id,
    message: "Pergunta enviada com sucesso",
  };
});
