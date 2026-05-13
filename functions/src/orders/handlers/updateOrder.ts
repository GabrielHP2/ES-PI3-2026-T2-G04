import { HttpsError, onCall } from "firebase-functions/v2/https";
import { cancelOrder } from "../repositories/ordersRepositories";
import { logger } from "firebase-functions/v2";
import { db } from "../../startups/shared/firebase";

/**
 * Cancel an existing order in the system.
 *
 * Expected request.data structure:
 * data: {
 *   orderId: string,            // ID da ordem para fazer o update
 * }
 *
 * Returns: { orderId: string, message: string }
 */
export const cancelOrderCallable = onCall(
  { invoker: "public" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }

    const uid = request.auth.uid;
    const order = request.data as { orderId: string };

    if (!order) {
      throw new HttpsError("invalid-argument", "Informe uma ordem válida");
    }

    if (!order.orderId || order.orderId.trim() === "") {
      throw new HttpsError(
        "invalid-argument",
        "orderId é obrigatório e não pode estar vazio",
      );
    }
    const orderSnap = await db.collection("orders").doc(order.orderId).get();

    if (!orderSnap.exists) {
      throw new HttpsError("not-found", "Ordem não encontrada");
    }

    if (orderSnap.data()?.user_id !== uid) {
      throw new HttpsError(
        "permission-denied",
        "Esta ordem não pertence a você",
      );
    }

    try {
      await cancelOrder(order.orderId);

      return {
        orderId: order.orderId,
        message: "Ordem cancelada com sucesso: ",
      };
    } catch (e: unknown) {
      logger.error(e);

      if (e instanceof HttpsError) {
        throw e;
      }

      throw new HttpsError("internal", "Não foi possível cancelar a ordem");
    }
  },
);
