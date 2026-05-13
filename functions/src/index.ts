import { initializeApp } from "firebase-admin/app";
import { setGlobalOptions } from "firebase-functions/v2";

setGlobalOptions({
  maxInstances: 2,
  region: "southamerica-east1",
  invoker: "public",
});

initializeApp();

export * from "./auth";
export * from "./startups";
export * from "./exchange";
export * from "./orders";
export * from "./balcony";
