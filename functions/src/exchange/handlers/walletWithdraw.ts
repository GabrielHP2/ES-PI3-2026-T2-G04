// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { HttpsError, onCall } from "firebase-functions/https";
import { logger } from "firebase-functions";

import { makeTransaction } from "../repositories/makeTransaction";
import { getBalance } from "../repositories/getBalance";
import { WalletType } from "../types/walletType";
import {
  subtract,
  toDecimal,
  toString,
  isLessThan,
} from "../../shared/decimalUtils";
import { db } from "../../shared/firebase";

export const walletWithdraw = onCall(async (request) => {
  // Decodifica o token do usuário e verifica se ele tem um id válido
  if (!request.auth) {
    logger.error("Error from walletWithdraw: Usuário não autenticado");
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const { withdrawQuantity } = request.data as {
    withdrawQuantity: number | string;
  };

  // Verifica se a quantidade de saque foi fornecida
  if (
    withdrawQuantity === undefined ||
    withdrawQuantity === null ||
    withdrawQuantity === ""
  ) {
    logger.error(
      "Error from walletWithdraw: Falha ao obter quantidade de saque",
    );
    throw new HttpsError("not-found", "Falha ao obter quantidade de saque");
  }

  let withdrawAmount;
  try {
    withdrawAmount = toDecimal(withdrawQuantity);
  } catch {
    logger.error("Error from walletWithdraw: Valor de saque inválido");
    throw new HttpsError("invalid-argument", "Valor de saque inválido");
  }

  const userId = request.auth.uid;

  // Pega a referência da carteira do usuário no BD
  const walletRef = db.collection("wallets").doc(userId);
  const snapshot = await walletRef.get();

  // Verifica se a carteira do usuário existe, caso contrário, cria uma nova carteira com saldo zero
  if (!snapshot.exists) {
    await walletRef.set({ availableBalance: "0.00", blockedBalance: "0.00" });
  }

  // Pega o saldo disponível do usuário no BD
  const balances = (await getBalance(userId)) as WalletType;
  const currentBalance = toDecimal(balances.availableBalance);

  // Verifica se a quantidade de saque é válida
  if (
    isLessThan(withdrawAmount, 1) ||
    isLessThan(currentBalance, withdrawAmount)
  ) {
    logger.error("Error from walletWithdraw: Valor de saque inválido");
    throw new HttpsError("invalid-argument", "Valor de saque inválido");
  }

  // Calcula o novo saldo subtraindo a quantidade de saque do saldo atual com precisão
  const newBalance = subtract(currentBalance, withdrawAmount);

  // Atualiza o saldo disponível do usuário no banco de dados
  await db
    .collection("wallets")
    .doc(userId)
    .set({ availableBalance: toString(newBalance) }, { merge: true });

  // Registra a transação de saque no banco de dados e obtém os detalhes da transação criada
  const transaction = await makeTransaction(
    userId,
    "expense",
    toString(withdrawAmount),
  );

  return { newBalance: toString(newBalance), transaction };
});
