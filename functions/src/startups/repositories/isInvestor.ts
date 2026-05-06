// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import { db } from "../shared/firebase";

// Verifica se o array "investing" contem o ID da startup repassada
export async function isInvestor(userId: string, startupId: string) : Promise<boolean> {
    
    const snapshot = await db.collection("usuarios").doc(userId).get();
    
    const userData = snapshot.data();
    
    // usar outro nome pro campo?
    return userData!.investing.includes(startupId);
}