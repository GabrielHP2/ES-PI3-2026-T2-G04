import {initializeApp} from "firebase-admin/app";
import {setGlobalOptions} from "firebase-functions";


setGlobalOptions({ maxInstances: 10 });

initializeApp();

export * from "./auth";
export * from "./startups";

/*
import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

// Tentei fazer do jeito do professor mas continuava dando erro,
// vou tentar fazer do jeito v2 que eu achei na documentação oficial;
// Link da documentação para a v2: https://firebase.google.com/docs/functions/version-comparison

admin.initializeApp();
const db = admin.firestore();
const collectionStartups = db.collection("startups");

// Function de TESTE
export const helloWorld = onRequest(
  {
    region: "southamerica-east1",
  },
  (req, res) => {
    if (req.method === "GET") {
      console.log("Esta mensagem é gravada nos logs da função");
      res.send("Hello world!");
    }

  },
);


exports.addSampleStartup = onRequest(
  {region: "southamerica-east1"},
  async (req, res) => {
    if (req.method !== "POST") {
      res.set("Allow", "POST");
      res.status(405).json({
        error: "Metodo nao permitido. Use POST.",
      });
      return;
    }

    const startup = {
      nome_startup: "GGTireShop",
      capital_aportado_startup: 40000,
      // estagio_startup: "nova ideia",
      // setor_startup: "tech",
    };
    try {
      const docRef = await collectionStartups.add(startup);
      res.status(201).json({
        message: "Startup exemplo inserida com sucesso.",
        id: docRef.id,
      });
    } catch (e) {
      console.error("Erro ao inserir a startup de exemplo: ", e);
      res.status(500).json({
        error: "Erro ao inserir a startup de exemplo.",
      });
    }
  },
);

exports.deleteStartup = onRequest(
  {
    region: "southamerica-east1",
  },
  async (req, res) => {
    // try {
    // Desafio matheus: pegar o startupId pela requisição
    // const toDelete = await req.body().JSON();

    // const startupId = "toDelete.docId";
    const startupId = "gZwbd4nsGd8zCbux9uhp";
    const writeResult = await collectionStartups.doc(startupId).delete();

    writeResult.isEqual;
    res
      .status(201)
      .json({message: "Startup provavelmente excluida.", id: startupId});
    // } catch (e) {}
  },
);

exports.showStartupByName = onRequest(
  {
    region: "southamerica-east1",
  },
  async (req, res) => {
    // Busca de startups que sejam
    const snapshot = await collectionStartups
      .where("nome_startup", "==", "VizioAi")
      .get();
    const startups: FirebaseFirestore.DocumentData[] = [];
    snapshot.forEach((doc) => {
      startups.push(doc.data());
    });
    res.status(200).json(startups);
  },
);
*/