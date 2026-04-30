import { onCall, HttpsError } from "firebase-functions/https";
import { getStartupById } from "../repositories/getStartupById";

export const getStartupDetails = onCall(async (request) => {
  const startupId = request.data?.id;

  if (startupId) {
    throw new HttpsError("invalid-argument", "Informe o id da startup");
  }

  const startup = await getStartupById(startupId);

  return startup;
});
