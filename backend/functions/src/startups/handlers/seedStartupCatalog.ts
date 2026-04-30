import { onCall } from "firebase-functions/https";
import { seedDemoStartups } from "../repositories/startupRepositories";

export const seedStartupCatalog = onCall(async (request) => {
  const startupIds = await seedDemoStartups();

  return {
    count: startupIds.length,
    ids: startupIds,
  };
});
