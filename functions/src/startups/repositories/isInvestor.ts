// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { db } from "../shared/firebase";
import * as logger from "firebase-functions/logger";

// Verifica se o array "investing" contem o ID da startup repassada
export async function isInvestor(
  userId: string,
  startupId: string,
): Promise<boolean> {
  try {
    const snapshot = await db.collection("wallets").doc(userId).get();

    const userData = snapshot.data();

    const holdings = userData?.holdings;
    if (!Array.isArray(holdings)) {
      logger.warn(
        `isInvestor: holdings is not an array for user=${userId}`,
        { userId, holdings }
      );
      return false;
    }

    for (const h of holdings) {
      if (typeof h === "string") {
        if (h === startupId) return true;
        continue;
      }

      if (h && typeof h === "object") {
        // Verifica primeiro startup_id que no seu banco é uma string (ou pode ser array)
        if (h.startup_id != null) {
          if (Array.isArray(h.startup_id)) {
            for (const p of h.startup_id) {
              if (p != null && String(p) === startupId) return true;
            }
          } else {
            if (String(h.startup_id) === startupId) return true;
          }
        }

        const candidates = [] as any[];
        // outros campos únicos possíveis
        if (h.startupId != null) candidates.push(h.startupId);
        if (h.id != null) candidates.push(h.id);
        if (h.startup != null) candidates.push(h.startup);

        for (const c of candidates) {
          if (c != null && String(c) === startupId) return true;
        }
      } else {
        logger.warn(`isInvestor: unexpected holding type for user=${userId}`, {
          userId,
          holding: h,
        });
      }
    }

    return false;
  } catch (err) {
    logger.error(`isInvestor: error checking holdings for user=${userId}`, {
      error: err,
      userId,
      startupId,
    });
    throw err;
  }
}
