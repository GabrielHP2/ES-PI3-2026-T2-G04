import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

// Tentei fazer do jeito do professor mas continuava dando erro,
// vou tentar fazer do jeito v2 que eu achei na documentação oficial;
// Link da documentação para a v2: https://firebase.google.com/docs/functions/version-comparison

admin.initializeApp();
const db = admin.firestore();
const collectionStartups = db.collection("startups");

export const addSampleStartup = onRequest(
  {region: "southamerica-east1"},
  async (req, res) => {
    const startup = {
      nome_startup: "GGTireShop",
      capital_aportado_startup: 40000,
      // estagio_startup: "nova ideia",
      // setor_startup: "tech",
    };
    try {
      const docRef = await collectionStartups.add(startup);
      res.send(`Startup exemplo inserida. Referencia: ${docRef.id}`);
    } catch (e: unknown) {
      console.error("Erro ao inserir a startup de exemplo: ", e);
      res.send("Erro ao inserir a startup de exemplo: ");
    }
  },
);

export const deleteStartup = onRequest(
  {
    region: "southamerica-east1",
  },
  async (req, res) => {
    // try {
    // Desafio matheus: pegar o startupId pela requisição
    const startupId = "gZwbd4nsGd8zCbux9uhp";
    const writeResult = await collectionStartups.doc(startupId).delete();

    writeResult.isEqual;
    res.send("Exclusão provavelmente realizada");
    // } catch (e) {}
  },
);
