// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { logger } from "firebase-functions";

import { PaymentType, WalletType } from "../types/walletType";
import { getBalance } from "../repositories/getBalance";
import { makeTransaction } from "../repositories/makeTransaction";

const db = getFirestore();

export const walletDeposit = onCall(async (request) => {
  // Decodifica o token do usuário e verifica se ele tem um id válido
  if (!request.auth) {
    logger.error("Error from walletDeposit: Usuário não autenticado");
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const { depositQuantity, paymentMethod } = request.data as {
    depositQuantity: number;
    paymentMethod: PaymentType;
  };

  // Verifica se a quantidade de depósito foi fornecida
  if (!depositQuantity) {
    logger.error(
      "Error from walletDeposit: Falha ao obter quantidade de depósito",
    );
    throw new HttpsError("not-found", "Falha ao obter quantidade de depósito");
  }

  // Verifica se a forma de pagamento foi fornecida
  if (!paymentMethod) {
    logger.error(
      "Error from walletDeposit: Forma de pagamento não especificada",
    );
    throw new HttpsError("not-found", "Forma de pagamento não especificada");
  }

  // Verifica se a quantidade de depósito é válida
  if (depositQuantity < 1) {
    logger.error("Error from walletDeposit: Valor de depósito inválido");
    throw new HttpsError("invalid-argument", "Valor de depósito inválido");
  }

  const userId = request.auth.uid;

  // Pega a referência da carteira do usuário no BD
  const walletRef = db.collection("wallets").doc(userId);
  const snapshot = await walletRef.get();

  // Verifica se a carteira do usuário existe, caso contrário, cria uma nova carteira com saldo zero
  if (!snapshot.exists) {
    await walletRef.set({ availableBalance: 0, blockedBalance: 0 });
  }

  // Pega o saldo disponível do usuário no BD
  const balances = (await getBalance(userId)) as WalletType;
  const currentBalance = balances.availableBalance;

  // Calcula o novo saldo somando a quantidade de depósito ao saldo atual
  const newBalance = currentBalance + depositQuantity;

  // Atualiza o saldo disponível do usuário no banco de dados
  await db
    .collection("wallets")
    .doc(userId)
    .set({ availableBalance: newBalance }, { merge: true });

  // Registra a transação de depósito no banco de dados e obtém os detalhes da transação criada
  const transaction = await makeTransaction(
    userId,
    "income",
    depositQuantity,
    paymentMethod,
  );

  return { newBalance, transaction };
});
