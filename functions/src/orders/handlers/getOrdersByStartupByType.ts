import { HttpsError, onCall } from "firebase-functions/v2/https";
import { db } from "../../startups/shared/firebase";
import { logger } from "firebase-functions/v2";
import { Order } from "../types/orderType";

const orderCollection = db.collection("orders");

export const getOrdersByStartupBytype = onCall(async (request) => {
  if (!request.auth) {
    logger.error("Error from getOrdersByStartupBytype: User not authenticated");
    throw new HttpsError("unauthenticated", "User not authenticated");
  }

  const { startupId, type } = request.data;

  if (!startupId || typeof startupId !== "string") {
    logger.error(
      "Error from getOrdersByStartupBytype: startupId é obrigatório",
    );
    throw new HttpsError("invalid-argument", "startupId é obrigatório.");
  }

  if (!type || typeof type !== "string") {
    logger.error("Error from getOrdersByStartupBytype: type é obrigatório");
    throw new HttpsError("invalid-argument", "type é obrigatório.");
  }

  const validTypes = ["buy", "sell"];

  if (!validTypes.includes(type)) {
    logger.error("Error from getOrdersByStartupBytype: type inválido");
    throw new HttpsError("invalid-argument", "type inválido.");
  }

  try {
    const ordersSnapshot = await orderCollection
      .where("startup_id", "==", startupId)
      .where("type", "==", type)
      .orderBy("createdAt", "desc")
      .limit(50)
      .get();

    if (ordersSnapshot.empty) {
      logger.info(
        `Nenhuma ordem encontrada para startupId=${startupId} e type=${type}`,
      );
      return { orders: [] };
    }

    const orders: Order[] = ordersSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...(doc.data() as Omit<Order, "id">),
    }));

    logger.info(`Listadas ${orders.length} da startupId=${startupId}`);
    return { orders };
  } catch (error) {
    logger.error("Erro ao listar ordens:", error);
    throw new HttpsError("internal", "Erro ao listar ordens.");
  }
});
