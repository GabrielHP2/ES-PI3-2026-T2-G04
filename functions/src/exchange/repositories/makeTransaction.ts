// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { Timestamp } from "firebase-admin/firestore";

import {
  TransactionType,
  PaymentType,
  TransactionModel,
  TransactionData,
} from "../types/walletType";
import { toDecimal, toString } from "../../shared/decimalUtils";
import { db } from "../../shared/firebase";

export async function makeTransaction(
  userId: string,
  type: TransactionType,
  amount: number | string,
  payMethod?: PaymentType,
  tradeId?: string,
) {
  // Cria um objeto com os dados da transação com precisão decimal
  const amountDecimal = toDecimal(amount);
  const finalAmount =
    type === "expense" ? amountDecimal.negated() : amountDecimal;

  const transactionData: TransactionData = {
    amountBRL: toString(finalAmount), // Armazenado como string com precisão
    description:
      type === "expense"
        ? "Saque realizado" // Alterna a descrição dependendo do tipo da transação
        : `Depósito via ${payMethod}`,
    type,
    userId,
    createdAt: Timestamp.now(),
  };

  // Adiciona o tradeId ao objeto de dados da transação caso ele seja fornecido
  if (tradeId !== undefined) transactionData.tradeId = tradeId;

  // Registra a transação no banco de dados e retorna os detalhes da transação criada
  if (type === "income") {
    return await db
      .collection("transactions")
      .add(transactionData)
      .then((ref) => {
        return ref.get();
      })
      .then((snapshot) => {
        const data = snapshot.data() as TransactionModel;
        return data;
      });
  }

  return await db
    .collection("transactions")
    .add(transactionData)
    .then((ref) => {
      return ref.get();
    })
    .then((snapshot) => {
      const data = snapshot.data() as TransactionModel;
      return data;
    });
}
