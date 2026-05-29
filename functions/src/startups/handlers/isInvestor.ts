// João Pedro Panza Mainieri - 25006642;
import { isInvestor } from "../repositories/isInvestor";
import { HttpsError, onCall } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

export const isUserInvestor = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("invalid-argument", "Usuário não autenticado");
  }
  const uid = request.auth.uid;
  const data = request.data as {
    startupId: string;
  };
  if (!data) {
    throw new HttpsError("invalid-argument", "startupId inválido");
  }

  try {
    const boolInvestor: boolean = await isInvestor(uid, data.startupId);
    return {
      isInvestor: boolInvestor,
    };
  } catch (err) {
    logger.error("isUserInvestor: erro ao verificar investidor", {
      error: err,
      uid,
      startupId: data.startupId,
    });
    throw new HttpsError(
      "internal",
      "Erro ao verificar se usuário é investidor",
    );
  }
});
