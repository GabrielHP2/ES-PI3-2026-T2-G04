import { getFirestore } from "firebase-admin/firestore";

//Importar tipos necessários
import { Startup } from "../types/startupType";

const db = getFirestore();
const startupCol = db.collection("startups");

export async function getStartupDetailsById(id: string): Promise<Startup> {
  const snapshot = await startupCol.doc(id).get();

  if (!snapshot.exists) {
    throw new Error(`Startup com id: "${id}" não encontrada`);
  }

  const startupData = snapshot.data() as Startup;
  return startupData;
}
