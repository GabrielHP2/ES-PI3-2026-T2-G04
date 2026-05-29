// João Pedro Panza Mainieri - 25006642;
import Decimal from "decimal.js";

/**
 * Configurar Decimal.js para precisão monetária (2 casas decimais)
 */
Decimal.set({
  precision: 28,
  rounding: Decimal.ROUND_HALF_UP,
  toExpNeg: -7,
  toExpPos: 21,
});

/**
 * Converte um valor numérico para Decimal
 */
export function toDecimal(value: number | string): Decimal {
  if (typeof value === "string") {
    // Se for string, assume que é um valor já convertido
    return new Decimal(value);
  }
  return new Decimal(value.toString());
}

/**
 * Converte Decimal para número (com 2 casas decimais)
 */
export function toNumber(decimal: Decimal): number {
  return parseFloat(decimal.toFixed(2));
}

/**
 * Converte Decimal para string (com 2 casas decimais)
 */
export function toString(decimal: Decimal): string {
  return decimal.toFixed(2);
}

/**
 * Soma dois valores monetários com precisão
 */
export function add(
  a: number | string | Decimal,
  b: number | string | Decimal,
): Decimal {
  const decimalA = typeof a === "object" ? a : toDecimal(a);
  const decimalB = typeof b === "object" ? b : toDecimal(b);
  return decimalA.plus(decimalB);
}

/**
 * Subtrai dois valores monetários com precisão
 */
export function subtract(
  a: number | string | Decimal,
  b: number | string | Decimal,
): Decimal {
  const decimalA = typeof a === "object" ? a : toDecimal(a);
  const decimalB = typeof b === "object" ? b : toDecimal(b);
  return decimalA.minus(decimalB);
}

/**
 * Multiplica dois valores com precisão (ex: preço × quantidade)
 */
export function multiply(
  a: number | string | Decimal,
  b: number | string | Decimal,
): Decimal {
  const decimalA = typeof a === "object" ? a : toDecimal(a);
  const decimalB = typeof b === "object" ? b : toDecimal(b);
  return decimalA.times(decimalB);
}

/**
 * Divide dois valores com precisão
 */
export function divide(
  a: number | string | Decimal,
  b: number | string | Decimal,
): Decimal {
  const decimalA = typeof a === "object" ? a : toDecimal(a);
  const decimalB = typeof b === "object" ? b : toDecimal(b);
  return decimalA.dividedBy(decimalB);
}

/**
 * Compara se a é menor que b
 */
export function isLessThan(
  a: number | string | Decimal,
  b: number | string | Decimal,
): boolean {
  const decimalA = typeof a === "object" ? a : toDecimal(a);
  const decimalB = typeof b === "object" ? b : toDecimal(b);
  return decimalA.lessThan(decimalB);
}

/**
 * Compara se a é menor ou igual que b
 */
export function isLessThanOrEqual(
  a: number | string | Decimal,
  b: number | string | Decimal,
): boolean {
  const decimalA = typeof a === "object" ? a : toDecimal(a);
  const decimalB = typeof b === "object" ? b : toDecimal(b);
  return decimalA.lessThanOrEqualTo(decimalB);
}

/**
 * Compara se a é maior que b
 */
export function isGreaterThan(
  a: number | string | Decimal,
  b: number | string | Decimal,
): boolean {
  const decimalA = typeof a === "object" ? a : toDecimal(a);
  const decimalB = typeof b === "object" ? b : toDecimal(b);
  return decimalA.greaterThan(decimalB);
}

/**
 * Compara se a é maior ou igual que b
 */
export function isGreaterThanOrEqual(
  a: number | string | Decimal,
  b: number | string | Decimal,
): boolean {
  const decimalA = typeof a === "object" ? a : toDecimal(a);
  const decimalB = typeof b === "object" ? b : toDecimal(b);
  return decimalA.greaterThanOrEqualTo(decimalB);
}

/**
 * Compara se a é igual a b
 */
export function isEqual(
  a: number | string | Decimal,
  b: number | string | Decimal,
): boolean {
  const decimalA = typeof a === "object" ? a : toDecimal(a);
  const decimalB = typeof b === "object" ? b : toDecimal(b);
  return decimalA.equals(decimalB);
}

/**
 * Calcula a média aritmética
 */
export function average(values: (number | string | Decimal)[]): Decimal {
  if (values.length === 0) {
    return new Decimal(0);
  }
  const sum = values.reduce<Decimal>((acc, val) => {
    const decimal = val instanceof Decimal ? val : toDecimal(val);
    return acc.plus(decimal);
  }, new Decimal(0));
  return sum.dividedBy(values.length);
}

/**
 * Formata valor para exibição (BRL)
 */
export function formatBRL(value: number | string | Decimal): string {
  const decimal = typeof value === "object" ? value : toDecimal(value);
  const num = parseFloat(decimal.toFixed(2));
  return new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL",
  }).format(num);
}
