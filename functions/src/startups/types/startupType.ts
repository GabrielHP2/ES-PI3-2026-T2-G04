// João Pedro Panza Mainieri - RA: 25006642

import { Timestamp } from "firebase-admin/firestore";

export type StartupStatus = "ativa" | "inativa" | "encerrada";

export type StartupStage = "nova" | "operacao" | "expansao";

export type StartupVisibility = "publica" | "privada";

export interface CorporateMember {
  name: string;
  role: string;
  equity_percent: number;
  bio: string;
}

export interface Startup {
  id: string;
  name: string;
  token_symbol: string;
  icon: string;
  status: StartupStatus;
  stage: StartupStage;
  visibility: StartupVisibility;
  tags: string[];
  last_price: string; // Armazenado como string para precisão
  short_description: string;
  full_description: string;
  executive_summary: string;
  corporate_structure: CorporateMember[];
  pitch_video_url: string;
  website?: string;
  founded_at?: Timestamp | string;
  current_raised: string; // Armazenado como string para precisão
  tokens_issued: number;
  investors_count: number;
  updated_at: Timestamp;
}

export interface SimplifiedStartup {
  id: string;
  name: string;
  token_symbol: string;
  icon: string;
  stage: StartupStage;
  tags: string[];
  short_description: string;
  corporate_structure: CorporateMember[];
  current_raised: string; // Armazenado como string para precisão
  tokens_issued: number;
  investors_count: number;
}

export interface StartupPriceHistory {
  // Isso vai ser uma sub-collection.
  price: string; // Armazenado como string para precisão
  quantity: number;
  executed_at: Timestamp; // Momento do registro
}
