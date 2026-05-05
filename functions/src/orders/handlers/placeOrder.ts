import {onCall, HttpsError} from "firebase-functions/v2/https";
import {createOrder} from "../repositories/ordersRepositories";
import {CreateOrderDTO} from "../types/orderType";

/**
 * Creates a new order in the system.
 *
 * Expected request.data structure:
 * {
 *   price: number,              // Preço por token
 *   quantity: number,           // Quantidade de tokens
 *   startup_id: string,         // ID da startup
 *   type: OrderType,           // "buy" ou "sell"
 *   token_symbol: string,       // Símbolo do token
 *   user_id: string            // ID do usuário
 * }
 *
 * Returns: { orderId: string, message: string }
 */
export const placeOrder = onCall(async (request) => {
  const order = request.data as CreateOrderDTO;

  if (!order) {
    throw new HttpsError("invalid-argument", "Informe uma ordem válida");
  }

  const docRef = await createOrder(
    order.price,
    order.quantity,
    order.startup_id,
    order.type,
    order.token_symbol,
    order.user_id
  );


  return {
    orderId: docRef.id,
    message: "Ordem criada com sucesso",
  };
});
