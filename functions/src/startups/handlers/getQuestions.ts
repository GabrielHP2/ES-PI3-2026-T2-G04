// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getQuestionsByStartupAndVisibility } from "../repositories/questionsRepositories";
import { QuestionInfo } from "../types/questionType";

/**
 * Retrieves questions for a specific startup.
 *
 * Expected request.data structure:
 * {
 *   startup_id: string,     // ID da startup
 *   is_public: boolean      // Se deve buscar apenas perguntas públicas
 * }
 *
 * Returns: Question[]
 */
export const getQuestions = onCall(async (request) => {
  // Verifica autenticação
  if (!request || !request.auth) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const questionInfo = request.data as QuestionInfo;
  if (!questionInfo.startup_id) {
    throw new HttpsError("not-found", "Falha ao identificar a startup");
  }

  try {
    const questions = await getQuestionsByStartupAndVisibility(
      questionInfo.startup_id,
      questionInfo.is_public,
    );
    return questions;
  } catch (err) {
    throw new HttpsError("data-loss", "Falha ao buscar as perguntas - " + err);
  }
});
