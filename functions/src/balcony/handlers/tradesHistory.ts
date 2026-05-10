import {getFirestore} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {onCall, HttpsError} from "firebase-functions/v2/https";

const db = getFirestore();

export const tradesHistory = onCall(async (request) => {
  if (!request.auth) {
    logger.error("Error from tradesHistory: User not authenticated");
    throw new HttpsError("unauthenticated", "User not authenticated.");
  }

  try {
    const tradesSnapshot = await db
      .collection("trades")
      .orderBy("executedAt", "desc")
      .get();

    if (tradesSnapshot.empty) {
      logger.info("Nenhuma trade encontrada");
      return {trades: []};
    }

    const trades = tradesSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    logger.info(`tradesHistory: ${trades.length}`);
    return {trades};
  } catch (error) {
    logger.error("Error from tradesHistory: ", error);
    throw new HttpsError("internal", "Failed to fetch trades history.");
  }
});
