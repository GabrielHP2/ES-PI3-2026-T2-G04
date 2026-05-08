import { HttpsError, onCall } from "firebase-functions/v2/https";
import { db } from "../../startups/shared/firebase";
import { logger } from "firebase-functions/v2";
import { Order } from "../types/orderType";

const orderCollection = db.collection("orders");

export const listOrdersByToken = onCall(async (request) => {
    if (!request.auth) {
        logger.error("Error from listOrdersByToken: Usuário não autenticado");
        throw new HttpsError("unauthenticated", "Usuário não autenticado.");
    }

    const {startupId} = request.data;
    const userId = request.auth.uid;

    if (!startupId || typeof startupId !== "string") {
        logger.error("Error from listOrdersByToken: startupId é obrigatório");
        throw new HttpsError("invalid-argument", "startupId é obrigatório.");
    }

    try {
        const snapshot = await orderCollection
            .where("userId", "==", userId)
            .where("startupId", "==", startupId)
            .orderBy("createdAt", "desc")
            .get();

        if (snapshot.empty) {
            return { orders: [] };
        }

        const orders: Order[] = snapshot.docs.map((doc) => ({
            id: doc.id,
            ...(doc.data() as Omit<Order, "id">),
        }));

        logger.info(`Listadas ${orders.length} da startupId=${startupId}`);
        return {orders};

    } catch (error) {
        logger.error("Erro ao listar ordens:", error);
        throw new HttpsError("internal", "Erro ao listar ordens.");
    }
});