// Lucas Leonel - RA: 25015188
import { getFirestore, Timestamp } from "firebase-admin/firestore";

const db = getFirestore();
// Tipos
interface PriceHistory {
  id: string;
  price: number;
  timestamp: Timestamp; // ajuste o nome do campo de data se for diferente
}

interface StartupSummary {
  id: string;
  name: string;
  token_symbol: string;
  last_price: number;
  price_history: PriceHistory[];
}

async function getStartupById(startupId: string): Promise<StartupSummary | null> {
  try {
    // 1. Busca pelo campo "id" dentro do documento
    const querySnap = await db
      .collection("startups")
      .where("id", "==", startupId)
      .get();

    if (querySnap.empty) {
      console.warn(`Startup "${startupId}" não encontrada.`);
      return null;
    }

    const startupDoc = querySnap.docs[0];
    const { name, token_symbol, last_price } = startupDoc.data();

    // Busca a subcoleção price_history
    const priceHistorySnap = await db
      .collection("startups")
      .doc(startupDoc.id)
      .collection("price_history")
      .get();

    const priceHistory: PriceHistory[] = priceHistorySnap.docs.map((doc) => ({
      id: doc.id,
      ...(doc.data() as Omit<PriceHistory, "id">),
      //por ser sub collection precisa dos pontin
    }));

    return {
      id: startupId,
      name,
      token_symbol,
      last_price,
      price_history: priceHistory,
    };
  } catch (error) {
    console.error("Erro ao buscar startup:", error);
    throw error;
  }
}

// Uso
const [agorSense, eduFlex, finNova, logiChain, saudeAi] = await Promise.all([
  getStartupById("agor-sense"),
  getStartupById("edu-flex"),
  getStartupById("fin-nova"),
  getStartupById("logi-chain"),
  getStartupById("saude-ai"),
]);