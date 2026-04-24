// Autor: Gabriel Henrique Pacagenlli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import { onRequest } from "firebase-functions/https";

import { User } from "../types/userType";
import {
  emailRegex,
  passwordRegex,
  cpfRegex,
  birthDateRegex,
  phoneNumberRegex,
} from "../types/regex";

const auth = getAuth();
const db = getFirestore();

export const signUp = onRequest(
  { region: "southamerica-east1" },
  async (request, response) => {
    try {
      // Recebe os dados vindos do corpo da requisição
      const user: User = request.body;

      // Verifica se nenhum dado é nulo
      if (
        !user.email ||
        !user.password ||
        !user.cpf ||
        !user.birthDate ||
        !user.phoneNumber
      ) {
        response
          .status(400)
          .json({ error: "Todos os campos são obrigatórios" });
        return;
      }

      // Faz um teste individual com cada dado pra verificar se ele bate com seu respectivo RegEx
      if (!emailRegex.test(user.email)) {
        response.status(400).json({ error: "Email inválido" });
        return;
      }

      if (!passwordRegex.test(user.password)) {
        response.status(400).json({ error: "Senha inválida" });
        return;
      }

      if (!cpfRegex.test(user.cpf)) {
        response.status(400).json({ error: "CPF inválido" });
        return;
      }

      if (!birthDateRegex.test(user.birthDate)) {
        response.status(400).json({ error: "Data de nascimento inválida" });
        return;
      }

      if (!phoneNumberRegex.test(user.phoneNumber)) {
        response.status(400).json({ error: "Número de telefone inválido" });
        return;
      }

      // Cria a conta do usuário por meio do authenticator, armazenando email, senha e nº de telefone
      await auth
        .createUser({
          email: user.email,
          password: user.password,
          phoneNumber: user.phoneNumber,

          // Após a criação, retorna no callback as infos do usuário registrado, como seu "uid"
        })
        .then(async (callback) => {
          // Armazena em um objeto o CPF e data de nascimento
          const data = {
            cpf: user.cpf,
            data_nascimento: user.birthDate,
          };

          // Insere na coleção "usuários" o CPF e data de nascimento, tendo o id do usuário como identificador
          await db.collection("usuarios").doc(callback.uid).set(data);
        });

      response.status(201).json({ message: "Usuário cadastrado" });
      return;
    } catch (e) {
      console.log("Erro ao realizar cadastro: ", e);
      response.status(500).json({ error: "Erro ao realizar cadastro" });
    }
  },
);
