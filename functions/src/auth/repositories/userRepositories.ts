// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { db } from "../../shared/firebase";

export async function getUserNameById(userId: string): Promise<string> {
  try {
    const userDoc = await db.collection("usuarios").doc(userId).get();

    if (!userDoc.exists) {
      throw new Error(`Usuário com ID: "${userId}" não encontrado`);
    }

    const userData = userDoc.data();
    return userData?.name || "";
  } catch (err) {
    throw new Error(`Falha ao buscar nome do usuário - ${err}`);
  }
}
