import { Timestamp } from "firebase-admin/firestore";

export type StartupStatus = "ativa" | "inativa" | "encerrada";

export type StartupEstagio = "nova" | "em_operacao" | "expansao";

export interface CorporateMember {
  name: string;
  role: string;
  equity_percent: number;
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
  status: StartupStatus;
  estagio: StartupEstagio;
  category: string;
  last_price: number;
  short_description: string;
  details: StartupDetails;
  //metrics: StartupMetrics; //Vamos usar depois, quando tivermos implementando o balcão de negociações
  created_at: Timestamp;
  updated_at: Timestamp;
}

export interface StartupPriceHistory {
  // Isso vai ser uma sub-collection.
  price: number; // Preço registrado no momento
  timestamp: Timestamp; // Momento do registro
}
