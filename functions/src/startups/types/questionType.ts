import {Timestamp} from "firebase-admin/firestore";

enum QuestionStatus {
  active = "active",
  deleted = "deleted",
}

export interface Question {
  answer_text?: string;
  answered_at?: Timestamp;
  answered_by_name?: string;
  created_at: Timestamp;
  is_answered: boolean;
  is_public: boolean;
  question_text: string;
  startup_id: string;
  status: QuestionStatus;
  user_id: string;
  user_name: string;
}
