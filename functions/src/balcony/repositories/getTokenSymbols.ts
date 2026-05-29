// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import * as logger from "firebase-functions/logger";
import { HttpsError } from "firebase-functions/https";

import { TradeType } from "../types/tradeType";
import { db } from "../../shared/firebase";

export async function getTokenSymbols(trades: TradeType[]) {
    
    try {

        // Pra cada trade, pega o id da startup e add em um array sem repetir
        const startupIds: string[] = [];
        trades.forEach((e) => {

            if (!startupIds.includes(e.startup_id)) {

                startupIds.push(e.startup_id);
            }
        });

        // Pega os símbolos dos tokens e o id da startup correspondente
        // pra usar como chave de cada símbolo no objeto que vai ser retornado

        const symbolsSnapshot = await db.collection("startups")
        .select("token_symbol", "id")
        .where("id", "in", startupIds)  
        .get();                         
        
        // OBS: Como só tem 5 startups cadastradas, não tem problema fazer o query assim,
        // mas se tivesse mais de 10, teria que fazer o query em partes
        // porque o Firestore tem um limite de 10 elementos nos querys feitos com "in"

        if (symbolsSnapshot.empty) {

            logger.error("Error from getTokenSymbols: Nenhum símbolo encontrado");
            throw new HttpsError("not-found", "Nenhum símbolo encontrado");
        }

        // Cria um objeto com os ids das startups 
        // como chaves e os símbolos dos tokens como valores
        const symbolsList: {[key: string]: any} = {};
        symbolsSnapshot.forEach((doc) => {

            const data = doc.data();
            const startupId = data.id;

            symbolsList[startupId] = data.token_symbol;
        });

        logger.info("Info from getTokenSymbols: OK");
        return symbolsList;


    } catch(error) {

        logger.error("Error from getTokenSymbols: Falha interna ao obter o símbolo dos tokens", error);
        throw new HttpsError("internal", "Falha interna ao obter o símbolo dos tokens", error);
    }
} 