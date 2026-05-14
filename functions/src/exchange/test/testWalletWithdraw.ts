// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";
import { onRequest } from "firebase-functions/https";
import { logger } from "firebase-functions";

import { makeTransaction } from "../repositories/makeTransaction";
import { getBalance } from "../repositories/getBalance";

import { WalletType } from "../types/walletType";

const db = getFirestore();

export const testWalletWithdraw = onRequest(async (request, response) => {
  try {
    const { withdrawQuantity } = request.body;

    // Verifica se a quantidade de saque foi fornecida
    if (!withdrawQuantity) {
      logger.error(
        "Error from walletWithdraw: Falha ao obter quantidade de saque",
      );
      response
        .status(400)
        .json({ error: "not-found, Falha ao obter quantidade de saque" });
    }

    const userId = "teste";

    // Pega a referência da carteira do usuário no BD
    const walletRef = db.collection("wallets").doc(userId);
    const snapshot = await walletRef.get();

    // Verifica se a carteira do usuário existe, caso contrário, cria uma nova carteira com saldo zero
    if (!snapshot.exists) {
      await walletRef.set({ availableBalance: "0.00", blockedBalance: "0.00" });
    }

    // Pega o saldo atual do usuário no BD
    const balances = (await getBalance(userId)) as WalletType;
    const currentBalance = Number(balances.availableBalance);
    const withdrawAmount = Number(withdrawQuantity);

    if (Number.isNaN(withdrawAmount)) {
      logger.error("Error from walletWithdraw: Valor de saque inválido");
      response
        .status(400)
        .json({ erro: "invalid-argument, Valor de saque inválido" });
      return;
    }

    // Verifica se a quantidade de saque é válida
    if (withdrawAmount < 1 || withdrawAmount > currentBalance) {
      logger.error("Error from walletWithdraw: Valor de saque inválido");
      response
        .status(400)
        .json({ erro: "invalid-argument, Valor de saque inválido" });
      return;
    }

    // Calcula o novo saldo subtraindo a quantidade de saque do saldo atual
    const newBalance = (currentBalance - withdrawAmount).toFixed(2);

    // Atualiza o saldo disponível do usuário no banco de dados
    await db
      .collection("wallets")
      .doc(userId)
      .set({ availableBalance: newBalance }, { merge: true });

    // Registra a transação de saque no banco de dados e obtém os detalhes da transação criada
    const transaction = await makeTransaction(
      userId,
      "expense",
      withdrawQuantity,
    );

    response.status(200).json({ newBalance, transaction });
  } catch (err) {
    response.status(500).json({ error: "Falha ao fazer o saque: ", err });
    return;
  }
});
