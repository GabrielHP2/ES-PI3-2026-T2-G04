// Autor: Gabriel Henrique Pacagenlli Pagliato   RA: 25016528

import { getFirestore } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import { onRequest } from "firebase-functions/https";

import { User } from "../types/userType";
import {
  emailRegex,
  passwordRegex,
  birthDateRegex,
  phoneNumberRegex,
} from "../types/regex";

const auth = getAuth();
const db = getFirestore();

function isValidCpf(cpf: string): boolean {
  if (!/^\d{11}$/.test(cpf)) {
    return false;
  }

  if (/^(\d)\1{10}$/.test(cpf)) {
    return false;
  }

  let sum = 0;
  for (let i = 0; i < 9; i++) {
    sum += Number(cpf[i]) * (10 - i);
  }
  let remainder = sum % 11;
  const firstDigit = remainder < 2 ? 0 : 11 - remainder;
  if (Number(cpf[9]) !== firstDigit) {
    return false;
  }

  sum = 0;
  for (let i = 0; i < 10; i++) {
    sum += Number(cpf[i]) * (11 - i);
  }
  remainder = sum % 11;
  const secondDigit = remainder < 2 ? 0 : 11 - remainder;

  return Number(cpf[10]) === secondDigit;
}

export const signUp = onRequest(
  { region: "southamerica-east1" },
  async (request, response) => {
    try {
      // Recebe os dados vindos do corpo da requisição
      const user: User = request.body;

      // Verifica se nenhum dado é nulo
      if (
        !user.name ||
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

      const normalizedEmail = user.email.trim().toLowerCase();
      const normalizedCpf = user.cpf.replace(/\D/g, "");
      const normalizedPhone = user.phoneNumber.trim().replace(/\s+/g, "");

      // Faz um teste individual com cada dado pra verificar se ele bate com seu respectivo RegEx
      if (!emailRegex.test(normalizedEmail)) {
        response.status(400).json({ error: "Email inválido" });
        return;
      }

      if (!passwordRegex.test(user.password)) {
        response.status(400).json({ error: "Senha inválida" });
        return;
      }

      if (!isValidCpf(normalizedCpf)) {
        response.status(400).json({ error: "CPF inválido" });
        return;
      }

      if (!birthDateRegex.test(user.birthDate)) {
        response.status(400).json({ error: "Data de nascimento inválida" });
        return;
      }

      if (!phoneNumberRegex.test(normalizedPhone)) {
        response.status(400).json({ error: "Número de telefone inválido" });
        return;
      }

      await auth
        .createUser({
          email: normalizedEmail,
          password: user.password,
          phoneNumber: normalizedPhone,
        })
        .then(async (callback) => {
          const data = {
            uid: callback.uid,
            name: user.name,
            email: normalizedEmail,
            cpf: normalizedCpf,
            phoneNumber: normalizedPhone,
            birthDate: user.birthDate,
            createdAt: new Date(),
          };

          // Insere na coleção usuarios usando o uid como identificador
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
