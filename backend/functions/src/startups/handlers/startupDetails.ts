// João Pedro Panza Mainieri - RA: 25006642

import { onCall, HttpsError } from "firebase-functions/https";
import { getStartupById } from "../repositories/startupRepositories";

export const getStartupDetails = onCall(async (request) => {
  const startupId = request.data?.id;

  if (!startupId) {
    throw new HttpsError("invalid-argument", "Informe o id da startup");
  }

  const startup = await getStartupById(startupId);

  return startup;
});
