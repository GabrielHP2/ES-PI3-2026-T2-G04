// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { Timestamp } from "firebase-admin/firestore"

export interface QuestionType {

    userId: string,
    userName: string,
    questionText: string,
    createdAt: Timestamp,
}

export interface AnswerType {
    
    answeredById: string,
    answeredByName: string,
    answerText: string,
    answeredAt: Timestamp,
}

export interface MessageType {

    startupId: string,
    question: QuestionType,
    answer?: AnswerType,
    isPublic: boolean,
    isAnswered: boolean
}
