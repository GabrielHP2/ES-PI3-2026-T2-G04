// João Pedro Panza Mainieri - 25006642;
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { getOrdersByUser } from "../repositories/ordersRepositories";

export const listOrdersCallable = onCall(async (request) => {
  if (!request.auth) {
    logger.error("listOrdersCallable: Usuário não autenticado");
    throw new HttpsError("unauthenticated", "Usuário não autenticado.");
  }

  const userId = request.auth.uid;
  logger.info(`listOrdersCallable called by uid=${userId}`);

  try {
    const orders = await getOrdersByUser(userId);
    logger.info(
      `listOrdersCallable: returning ${orders.length} orders for uid=${userId}`,
    );
    return { orders };
  } catch (error) {
    logger.error("Erro em listOrdersCallable:", error);
    throw new HttpsError("internal", "Erro ao listar ordens.");
  }
});
