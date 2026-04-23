import {initializeApp} from "firebase-admin/app";
import {setGlobalOptions} from "firebase-functions";


setGlobalOptions({ maxInstances: 10 });

initializeApp();

export * from "./auth";
export * from "./startups";