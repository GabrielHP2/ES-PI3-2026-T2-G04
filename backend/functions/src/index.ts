import {initializeApp} from "firebase-admin/app";
import {setGlobalOptions} from "firebase-functions";
import {onRequest} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";


setGlobalOptions({ maxInstances: 10 });

initializeApp()

// Função de teste
export const helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

// Função de teste
export const randomNumber = onRequest((request, response) => {

    const number = Math.round(Math.random() * 1000);
    response.send(`O número sorteado foi: ${number}`);
    console.log(number);
});

export * from "./auth";
export * from "./startups";