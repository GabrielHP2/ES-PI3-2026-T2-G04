//Lucas Leonel - RA: 25015188
//Joao Pedro Maineri - RA: 25006642

import {
  getFirestore,
  QueryDocumentSnapshot,
  DocumentData,
} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {
  onCall,
  HttpsError,
  CallableRequest,
} from "firebase-functions/v2/https";
import { PriceHistoryResponseItem, TokenResponse } from "../types/tokenType";

const db = getFirestore();

async function getPriceHistory(
  startupDocId: string,
): Promise<PriceHistoryResponseItem[]> {
  const snap = await db
    .collection("startups")
    .doc(startupDocId)
    .collection("price_history")
    .orderBy("executed_at", "asc")
    .get();

  return snap.docs.map((doc: QueryDocumentSnapshot<DocumentData>) => {
    const data = doc.data();

    return {
      id: doc.id,
      price: String(data["price"] ?? "0.00"), // Manter como string para precisão (jao)
      quantity: (data["quantity"] as number | null) ?? null,
      executed_at: data["executed_at"],
    };
  });
}

export const tokensCatalog = onCall(async () => {
  const querySnap = await db
    .collection("startups")
    .select("name", "token_symbol", "last_price", "current_raised")
    .get();

  if (querySnap.empty) {
    logger.error(
      "Error from tokensCatalog: Falha ao buscar dados das startups",
    );
    throw new HttpsError("data-loss", "Falha ao buscar dados das startups");
  }

  const startups: TokenResponse[] = await Promise.all(
    querySnap.docs.map(
      async (startupDoc: QueryDocumentSnapshot<DocumentData>) => {
        const data = startupDoc.data();
        const history = await getPriceHistory(startupDoc.id);

        return {
          id: startupDoc.id,
          name: String(data["name"] ?? ""),
          token_symbol: String(data["token_symbol"] ?? ""),
          last_price: String(data["last_price"] ?? "0.00"), // Manter como string para precisão
          current_raised: String(data["current_raised"] ?? "0.00"), // Manter como string para precisão
          price_history: history,
        };
      },
    ),
  );

  return { startups };
});

export const getTokenByStartupId = onCall(
  async (request: CallableRequest<{ id: string }>) => {
    const startupDoc = await db
      .collection("startups")
      .doc(request.data.id)
      .get();

    if (!startupDoc.exists) {
      logger.error(
        "Error from tokensCatalogById: Falha ao buscar dados da startup",
      );
      throw new HttpsError("data-loss", "Falha ao buscar dados da startup");
    }

    const data = startupDoc.data() as DocumentData;
    const history = await getPriceHistory(startupDoc.id);

    const token: TokenResponse = {
      id: request.data.id,
      name: String(data["name"] ?? ""),
      token_symbol: String(data["token_symbol"] ?? ""),
      last_price: String(data["last_price"] ?? "0.00"),
      current_raised: String(data["current_raised"] ?? "0.00"),
      price_history: history,
    };

    return token;
  },
);
