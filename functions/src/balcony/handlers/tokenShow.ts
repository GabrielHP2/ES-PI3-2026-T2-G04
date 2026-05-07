// Lucas Leonel - RA: 25015188
import {getFirestore, Timestamp, QueryDocumentSnapshot, DocumentData} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {onCall, HttpsError, CallableRequest} from "firebase-functions/v2/https";

const db = getFirestore();

// função para pegar o price_history
async function getPriceHistory(startupDocId: string): Promise<
  Array<{ id: string; price: number; timestamp: number }>
> {
  const snap = await db
    .collection("startups")
    .doc(startupDocId)
    .collection("price_history")
    .get();

  return snap.docs.map((doc: QueryDocumentSnapshot<DocumentData>) => {
    const data = doc.data();
    return {
      id: doc.id,
      price: data.price,
      timestamp: (data.timestamp as Timestamp).toMillis(),
    };
  });
}

// listar todas as startups
export const tokensCatalog = onCall(async () => {
  const querySnap = await db
    .collection("startups")
    .select("name",
      "token_symbol",
      "last_price",
      "current_raised")
    .get();

  if (querySnap.empty) {
    logger.error("Error from tokensCatalog: Falha ao buscar dados das startups");
    throw new HttpsError("data-loss", "Falha ao buscar dados das startups");
  }

  const startups = await Promise.all(
    querySnap
      .docs
      .map(async (startupDoc: QueryDocumentSnapshot<DocumentData>) => {
        const {
          name,
          token_symbol,
          last_price,
          current_raised,
        } = startupDoc.data();
        return {
          id: startupDoc.id,
          name,
          token_symbol,
          last_price,
          current_raised,
          price_history: await getPriceHistory(startupDoc.id),
        };
      })
  );

  return {startups}; // por conta do promisse.all, o retorno só acontece depois de todas as startups terem sido processadas
});

// Busca uma startup pelo id
export const getTokenByStartupId = onCall(
  async (request: CallableRequest<{ id: string }>) => {
    const startupDoc = await db
      .collection("startups")
      .doc(request.data.id)
      .get();

    if (!startupDoc.exists) {
      logger.error("Error from tokensCatalogById: Falha ao buscar dados da startup");
      throw new HttpsError("data-loss", "Falha ao buscar dados da startup");
    }

    const {
      name,
      token_symbol,
      last_price,
      current_raised,
    } = startupDoc.data() as {
      name: string;
      token_symbol: string;
      last_price: number;
      current_raised: number;
    };

    return {
      id: request.data.id,
      name,
      token_symbol,
      last_price,
      current_raised,
      price_history: await getPriceHistory(startupDoc.id),
    };
  });
