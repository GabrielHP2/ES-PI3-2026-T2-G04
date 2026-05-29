//Lucas leonel - RA: 25015188

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { getOrdersByStartupAndType as fetchOrdersByStartupAndType } from "../repositories/ordersRepositories";
import { Order } from "../types/orderType";

/**
 * Fetches orders filtered by startup ID and order type.
 *
 * Expected request.data structure:
 * {
 *   startupId: string,  // ID da startup
 *   type: string,       // "buy" ou "sell"
 * }
 *
 * Returns: { orders: Order[] }
 */
export const getOrdersByStartupAndType = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Usuário não autenticado");
  }

  const { startupId, type } = request.data;

  if (!startupId || typeof startupId !== "string") {
    throw new HttpsError("invalid-argument", "startupId é obrigatório");
  }

  if (!type || typeof type !== "string") {
    throw new HttpsError("invalid-argument", "type é obrigatório");
  }

  const validTypes = ["buy", "sell"];
  if (!validTypes.includes(type)) {
    throw new HttpsError("invalid-argument", "type inválido");
  }

  const orders = await fetchOrdersByStartupAndType(
    startupId,
    type as Order["type"],
  );

  if (orders.length === 0) {
    logger.info(
      `Nenhuma ordem encontrada para startupId=${startupId} e type=${type}`,
    );
  } else {
    logger.info(`Listadas ${orders.length} ordens para startupId=${startupId}`);
  }

  return { orders };
});
