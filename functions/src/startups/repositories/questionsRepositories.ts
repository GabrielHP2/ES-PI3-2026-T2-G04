// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { db } from "../shared/firebase";
import {
  CreateQuestionDTO,
  QuestionStatus,
  Question,
} from "../types/questionType";
import {
  DocumentData,
  DocumentReference,
  Timestamp,
} from "firebase-admin/firestore";
import { logger } from "firebase-functions/v2";
import { HttpsError } from "firebase-functions/v2/https";

const questionsCollection = db.collection("questions");

export async function createQuestion(
  startupId: string,
  userId: string,
  userName: string,
  questionText: string,
  isPublic: boolean,
): Promise<DocumentReference<DocumentData>> {
  const data: CreateQuestionDTO = {
    startup_id: startupId,
    user_id: userId,
    user_name: userName,
    question_text: questionText,
    is_public: isPublic,
    is_answered: false,
    created_at: Timestamp.now(),
    status: QuestionStatus.active,
  };

  return await questionsCollection.add(data);
}

export async function getQuestionsByStartupAndVisibility(
  startupId: string,
  isPublic: boolean,
): Promise<Question[]> {
  const snapshot = await questionsCollection
    .where("startup_id", "==", startupId)
    .where("is_public", "==", isPublic)
    .get();
  if (snapshot.empty) {
    logger.error(
      "Error from getQuestionsByStartupAndVisibility: Falha ao buscar perguntas com essa visibilidade",
    );
    throw new HttpsError(
      "data-loss",
      "Falha ao buscar perguntas com essa visibilidade",
    );
  }

  const questions: Question[] = [];

  for (const doc of snapshot.docs) {
    const data = doc.data();
    questions.push({
      ...data,
    } as Question);
    logger.debug(
      `Debug from getQuestionsByStartupAndVisibility: ${JSON.stringify(questions)}`,
    );
  }
  logger.info("Info from getQuestionsByStartupAndVisibility: OK");

  return questions;
}
