import { isInvestor } from "../repositories/isInvestor";
import { HttpsError, onCall } from "firebase-functions/https";

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

  const boolInvestor: boolean = await isInvestor(uid, data.startupId);

  return {
    isInvestor: boolInvestor,
  };
});
