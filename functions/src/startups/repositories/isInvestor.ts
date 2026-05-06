// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { db } from "../shared/firebase";

// Verifica se o array "investing" contem o ID da startup repassada
export async function isInvestor(
  userId: string,
  startupId: string,
): Promise<boolean> {
  const snapshot = await db.collection("wallets").doc(userId).get();

  const userData = snapshot.data();

  // usar outro nome pro campo?
  const holdings = userData?.holdings;
  if (!Array.isArray(holdings)) return false;

  for (const h of holdings) {
    for (const p of h.startup_id) {
      if (p != null && String(p) === startupId) return true;
    }
  }

  return false;
}
