import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions";

setGlobalOptions({ maxInstances: 10, region: "southamerica-east1" });

initializeApp();

export * from "./auth";
export * from "./startups";
export * from "./exchange";
