import { Timestamp } from "firebase-admin/firestore";

export type StartupStatus = "ativa" | "inativa" | "encerrada";

export type StartupStage = "nova" | "operacao" | "expansao";

export type StartupVisibilitie = "publica" | "privada";

export interface CorporateMember {
  name: string;
  role: string;
  equity_percent: number;
  bio: string;
}

export interface StartupDetails {
  full_description: string;
  executive_summary: string;
  corporate_structure: CorporateMember[];
  pitch_video_url: string;
  website?: string;
  founded_at?: Timestamp | string;
}

export interface StartupMetrics {
  current_raised: number;
  tokens_emitidos: number;
  investors_count: number;
}

export interface Startup {
  name: string;
  token_symbol: string;
  icon: string;
  status: StartupStatus;
  estagio: StartupStage;
  visibilitie: StartupVisibilitie;
  category: string;
  last_price: number;
  short_description: string;
  details: StartupDetails;
  metrics: StartupMetrics;
  updated_at: Timestamp;
}

export interface StartupPriceHistory {
  // Isso vai ser uma sub-collection.
  price: number; // Preço registrado no momento
  timestamp: Timestamp; // Momento do registro
}
