// Autor: Gabriel Henrique Pacagenlli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import { onRequest } from "firebase-functions/https";

import { User } from "../types/userType";
import { emailRegex, passwordRegex, cpfRegex, birthDateRegex, phoneNumberRegex } from "../types/regex";


const auth = getAuth();
const db = getFirestore();

export const signUp = onRequest(async (request, response) => {

    try {

        const user: User = request.body;

        if (!user.email || !user.password || !user.cpf || !user.birthDate || !user.phoneNumber) {
            response.status(400).json({error: "Todos os campos são obrigatórios"});
            return;
        }


        if (!emailRegex.test(user.email)) {
            response.status(400).json({error: "Email inválido"});
            return;
        } 

        if (!passwordRegex.test(user.password)) {
            response.status(400).json({error: "Senha inválida"});
            return;
        } 

        if (!cpfRegex.test(user.cpf)) {
            response.status(400).json({error: "CPF inválido"});
            return;
        } 

        if (!birthDateRegex.test(user.birthDate)) {
            response.status(400).json({error: "Data de nascimento inválida"});
            return;
        }

        if (!phoneNumberRegex.test(user.phoneNumber)) {
            response.status(400).json({error: "Número de telefone inválido"});
            return;
        }

        await auth.createUser({

            email: user.email,
            password: user.password,
            phoneNumber: user.phoneNumber,

        }).then(async (callback) => {

            const data = {
                cpf: user.cpf,
                data_nascimento: user.birthDate
            }

            await db.collection('usuarios').doc(callback.uid).set(data);
        });

        response.status(201).json({message: "Usuário cadastrado"});
        return;

    } catch (e) {

        console.log("Erro ao realiza cadastro: ", e);
        response.status(500).json({error: "Erro ao realizar cadastro"})
    }
});