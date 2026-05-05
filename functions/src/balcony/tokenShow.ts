// Lucas Leonel - RA: 25015188
import { getFirestore, Timestamp,QueryDocumentSnapshot, DocumentData } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { onCall, HttpsError } from "firebase-functions/https";

const db = getFirestore();
interface PriceHistory {
  id: string;      
  price: number; 
  timestamp: Timestamp; 
}

export const tokensCatalog = onCall(async (request) =>{
    // 1. Busca pelo campo "id" dentro do documento
    const querySnap = await db
      .collection("startups")
      .select("name",
        "token_symbol",
        "last_price",
        "current_raised",
        )
      .where("id","==",request.data.id)
      .get();

    if (querySnap.empty) {
    logger.error(
      "Error from tokensCatalog: Falha ao buscar dados das startups",
    );
    throw new HttpsError("data-loss", "Falha ao buscar dados das startups");
  }

    const startupDoc = querySnap.docs[0]; //pega o elemento do get
    const { name, token_symbol, last_price, current_raised } = startupDoc.data();

    // Busca a subcoleção price_history
    const priceHistorySnap = await db
      .collection("startups")
      .doc(startupDoc.id)
      .collection("price_history")
      .get();

    const priceHistory: PriceHistory[] = priceHistorySnap.docs.map((doc: QueryDocumentSnapshot<DocumentData>) => ({
      id: doc.id,
      ...(doc.data() as Omit<PriceHistory, "id">),
      //por ser sub collection precisa dos pontin
    }));

    return {
      id: request.data.id,
      name,
      token_symbol,
      last_price,
      current_raised,
      price_history: priceHistory,
    };
});
