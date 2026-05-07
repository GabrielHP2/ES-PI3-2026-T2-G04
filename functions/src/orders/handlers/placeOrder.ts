import { onCall, HttpsError } from "firebase-functions/v2/https";
import { createOrder } from "../repositories/ordersRepositories";
import { CreateOrderDTO, OrderType } from "../types/orderType";
import { db } from "../../startups/shared/firebase";

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
      const totalcost = order.price * order.quantity;

      if (wallet.availableBalance < totalcost) {
        throw new HttpsError("failed-precondition", "Saldo insuficiente");
      }
      const newBalance = wallet.availableBalance - totalcost;
      const newBlockedBalance = wallet.blockedBalance + totalcost;

      transaction.update(walletRef, {
        availableBalance: newBalance,
        blockedBalance: newBlockedBalance,
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

  return {
    orderId: docRef.id,
    message: "Ordem criada com sucesso",
  };
});
