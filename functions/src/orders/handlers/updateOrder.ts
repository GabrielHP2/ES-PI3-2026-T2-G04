import {HttpsError, onCall} from "firebase-functions/v2/https";
import {updateOrder} from "../repositories/ordersRepositories";
import {UpdateOrderDTO} from "../types/orderType";
import {logger} from "firebase-functions/v2";

/**
 * Updates an existing order in the system.
 *
 * Expected request.data structure:
 * data: {
 *   orderId: string,            // ID da ordem para fazer o update
 *   quantityFilledNow: number,  // Quantidade de tokens preenchidos
 *   status: OrderStatus         // "open" | "partially" | "filled" | "cancelled"
 * }
 *
 * Returns: { orderId: string, message: string }
 */
export const updateOrderCallable = onCall(async (request) => {
  const order = request.data as UpdateOrderDTO;

  if (!order) {
    throw new HttpsError("invalid-argument", "Informe uma ordem válida");
  }

  if (!order.orderId || order.orderId.trim() === "") {
    throw new HttpsError(
      "invalid-argument",
      "orderId é obrigatório e não pode estar vazio",
    );
  }

  try {
    await updateOrder(
      order.orderId,
      order.quantityFilledNow,
      order.status,
    );

    return {
      orderId: order.orderId,
      message: "Ordem atualizada com sucesso: ",
    };
  } catch (e: unknown) {
    logger.error(e);

    if (e instanceof HttpsError) {
      throw e;
    }

    throw new HttpsError(
      "internal",
      "Não foi possível atualizar a ordem",
    );
  }
});
