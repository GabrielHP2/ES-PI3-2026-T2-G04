// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

// Deve ter formato local@dominio.tld, com letras/numeros e ._%+- antes do @, dominio valido depois do @ e sufixo com pelo menos 2 letras.
export const emailRegex: RegExp = RegExp(
  /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
);

// Deve ter 8-16 caracteres, sem espaços, 1 letra maiuscula e minuscula, 1 numero e 1 caractere especial.
export const passwordRegex: RegExp = RegExp(
  /^(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[^\w\d\s:])([^\s]){8,16}$/,
);

// Deve ter 11 digitos.
export const cpfRegex: RegExp = RegExp(/^\d{11}$/);

// Deve estar no formato dd/mm/aaaa, dia de 01 a 31, mes de 01 a 12 e ano com 4 digitos.
export const birthDateRegex: RegExp = RegExp(
  /^(0[1-9]|[1-2][0-9]|3[0-1])\/(0[1-9]|1[0-2])\/(\d{4})$/,
);

// Deve estar no formato +55 seguido de DDD (1-9 no primeiro digito) e numero com 9 ou 10 digitos.
// Ex: +5511987654321, +5511876543210
export const phoneNumberRegex: RegExp = RegExp(/^\+55[1-9]\d{9,10}$/);
