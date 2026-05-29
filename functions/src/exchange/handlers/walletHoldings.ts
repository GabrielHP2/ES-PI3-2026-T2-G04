// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { HttpsError, onCall } from "firebase-functions/https";
import { logger } from "firebase-functions";
import { getHoldings } from "../repositories/getHoldings";
import { db } from "../../shared/firebase";

export const walletHoldings = onCall(async (request) => {
  // Decodifica o token do usuário e verifica se ele tem um id válido
  if (!request.auth) {
    logger.error("Error from walletHoldings: Usuário não autenticado");
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  logger.info("walletHoldings: request recebida", {
    uid: request.auth.uid,
  });

  // Pega a referência da carteira do usuário no BD
  const walletRef = db.collection("wallets").doc(request.auth.uid);
  const snapshot = await walletRef.get();

  logger.info("walletHoldings: snapshot inicial", {
    uid: request.auth.uid,
    exists: snapshot.exists,
    data: snapshot.exists ? snapshot.data() : null,
  });

  // Verifica se a carteira do usuário existe, caso contrário, cria uma nova carteira com saldo zero
  if (!snapshot.exists) {
    logger.info("walletHoldings: criando carteira vazia", {
      uid: request.auth.uid,
    });

    await walletRef.set({
      availableBalance: "0.00",
      blockedBalance: "0.00",
      holdings: [],
    });
  }

  // Retorna os saldos disponível e bloqueado do usuário
  const holdings = await getHoldings(request.auth.uid);

  logger.info("walletHoldings: resposta final", {
    uid: request.auth.uid,
    holdings,
  });

  return holdings;
});
