//Lucas Leonel - RA: 25015188

import {HttpsError, onCall} from "firebase-functions/v2/https";
import {db} from "../../startups/shared/firebase";
import {logger} from "firebase-functions/v2";
import {Order} from "../types/orderType";

const orderCollection = db.collection("orders");

export const listOrders = onCall(async (request) => {
    if (!request.auth) {
        logger.error("Error from listOrders: Usuário não autenticado");
        throw new HttpsError("unauthenticated", "Usuário não autenticado.");
    }

    const userId = request.auth.uid; // pega o id do auth no login 

    try {
        const snapshot = await orderCollection
            .where("user_id", "==", userId)
            .orderBy("createdAt", "desc")
            .get();

        if (snapshot.empty) {
            logger.info(`Nenhuma ordem encontrada`);
            return {orders: []};
        }

        //map dos documentos
        const orders: Order[] = snapshot.docs.map((doc) => ({
            id: doc.id,
            ...(doc.data() as Omit<Order, "id">),
        }));

        logger.info(`Listadas ${orders.length} ordens`);

        return {orders};

    } catch (error) {
        logger.error("Erro ao listar ordens:", error);
        throw new HttpsError("internal", "Erro ao listar ordens.");
    }
});
