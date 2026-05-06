// João Pedro Panza Mainieri - RA: 25006642

import {onCall} from "firebase-functions/v2/https";
import {seedDemoStartups} from "../repositories/startupRepositories";

export const seedStartupCatalog = onCall(async () => {
  const startupIds = await seedDemoStartups();

  return {
    count: startupIds.length,
    ids: startupIds,
  };
});
