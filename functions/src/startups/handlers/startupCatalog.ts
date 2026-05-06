// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import {getFirestore} from "firebase-admin/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import {SimplifiedStartup} from "../types/startupType";

const db = getFirestore();

export const startupCatalog = onCall(async (request) => {
  // Decodifica o token do usuário e verifica se ele tem um id válido
  if (!request.auth) {
    logger.error("Error from startupCatalog: Usuário não autenticado");
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  // Pega no BD os campos do "select" respeitando os filtros do "where"
  const snapshot = await db
    .collection("startups")
    .select(
      "name",
      "stage",
      "tags",
      "icon",
      "token_symbol",
      "investors_count",
      "short_description",
      "corporate_structure",
      "tokens_issued",
      "current_raised",
    )
    .where("status", "==", "ativa")
    .where("visibility", "==", "publica")
    .get();

  // Verifica se nenhuma startup foi encontrada
  if (snapshot.empty) {
    logger.error(
      "Error from startupCatalog: Falha ao buscar dados das startups",
    );
    throw new HttpsError("data-loss", "Falha ao buscar dados das startups");
  }

  const startups: SimplifiedStartup[] = [];

  // Le os dados de cada documento e add ao array de startups
  for (const doc of snapshot.docs) {
    const data = doc.data();
    startups.push({
      id: doc.id,
      ...data,
    } as SimplifiedStartup);

    logger.debug(`Debug from startupCatalog: ${startups}`);
  }

  logger.info("Info from startupCatalog: OK");

  return startups;
});
