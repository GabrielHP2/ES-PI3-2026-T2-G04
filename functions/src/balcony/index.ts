// Lucas Leonel - RA: 25015188
import { getFirestore } from "firebase-admin/firestore";
import { doc, getDoc, collection, getDocs } from "firebase/firestore";
import { Timestamp } from "firebase/firestore";

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

async function getStartupSummaryById(startupId: string): Promise<StartupSummary | null> {
  try {
    const startupsRef = doc(db, "startups");
    const q = query(startupsRef, where("id", "==", startupId));
    const querySnap = await getDocs(q);

    if (querySnap.empty) {
      console.warn(`Startup "${startupId}" não encontrada.`);
      return null;
    }

    const startupDoc = querySnap.docs[0];
    const { name, token_symbol, last_price } = startupDoc.data();

    // 2. Busca a subcoleção price_history usando o doc ID real do Firestore
    const priceHistorySnap = await getDocs(
      collection(db, "startups", startupDoc.id, "price_history")
    );

    const priceHistory: PriceHistory[] = priceHistorySnap.docs.map((doc) => ({
      id: doc.id,
      ...(doc.data() as Omit<PriceHistory, "id">),
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