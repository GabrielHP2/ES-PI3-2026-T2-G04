// João Pedro Panza Mainieri - 25006642;
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { createOrder } from "../repositories/ordersRepositories";
import { CreateOrderDTO, OrderType } from "../types/orderType";
import { db } from "../../startups/shared/firebase";
import { matchOrders } from "../../orderBook_engine/handlers/matchEngine";
import {
  multiply,
  subtract,
  add,
  toString,
  toDecimal,
  isLessThan,
} from "../../shared/decimalUtils";

/**
 * Creates a new order in the system.
 *
 * Expected request.data structure:
 * {
 *   price: number,              // Preço por token
 *   quantity: number,           // Quantidade de tokens
 *   startup_id: string,         // ID da startup
 *   type: OrderType,           // "buy" ou "sell"
 *   token_symbol: string,       // Símbolo do token
 * }
 *
 * Returns: { orderId: string, message: string }
 */
export const placeOrder = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const order = request.data as CreateOrderDTO;

  if (!order) {
    throw new HttpsError("invalid-argument", "Informe uma ordem válida");
  }

  const walletRef = db.collection("wallets").doc(uid);

  await db.runTransaction(async (transaction) => {
    const walletSnap = await transaction.get(walletRef);

    if (!walletSnap.exists) {
      throw new HttpsError("not-found", "Carteira não encontrada");
    }

    const wallet = walletSnap.data()!;

    if (order.type == OrderType.buy) {
      // Calcula o custo total com precisão: price * quantity
      const totalcost = multiply(
        toDecimal(order.price),
        toDecimal(order.quantity),
      );
      const availableBalance = toDecimal(wallet.availableBalance);

      if (isLessThan(availableBalance, totalcost)) {
        throw new HttpsError("failed-precondition", "Saldo insuficiente");
      }

      const newBalance = subtract(availableBalance, totalcost);
      const newBlockedBalance = add(
        toDecimal(wallet.blockedBalance),
        totalcost,
      );

      transaction.update(walletRef, {
        availableBalance: toString(newBalance),
        blockedBalance: toString(newBlockedBalance),
      });
    } else if (order.type == OrderType.sell) {
      const holdings: any[] = wallet.holdings ?? [];

      const holdingIndex = holdings.findIndex(
        (h) => h.startup_id == order.startup_id,
      );

      if (holdingIndex === -1) {
        throw new HttpsError("not-found", "Holding não encontrada");
      }

      const holding = holdings[holdingIndex];

      if (holding.token_balance < order.quantity) {
        throw new HttpsError("failed-precondition", "Tokens insuficientes");
      }

      holdings[holdingIndex] = {
        ...holding,
        token_balance: holding.token_balance - order.quantity,
        blocked_token_balance: holding.blocked_token_balance + order.quantity,
      };

      transaction.update(walletRef, { holdings });
    }
  });

  const docRef = await createOrder(
    order.price,
    order.quantity,
    order.startup_id,
    order.type,
    order.token_symbol,
    uid!,
  );

  await matchOrders(order.startup_id);

  return {
    orderId: docRef.id,
    message: "Ordem criada com sucesso",
  };
});
