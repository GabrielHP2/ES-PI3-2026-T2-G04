import {db} from "../../startups/shared/firebase";
import {CreateOrderDTO, Order, OrderStatus, OrderType} from "../types/orderType";
import {logger} from "firebase-functions/v2";
import {HttpsError} from "firebase-functions/v2/https";
import {DocumentData, DocumentReference, Timestamp} from "firebase-admin/firestore";

const orderCollection = db.collection("orders");

//  getAll
export async function getOrders(): Promise<Order[]> {
  const snapshot = await orderCollection.get();
  if (snapshot.empty) {
    logger.error("Error from getOrders: Falha ao buscar dados de ordens");
    throw new HttpsError("data-loss", "");
  }

  const orders: Order[] = [];

  for (const doc of snapshot.docs) {
    const data = doc.data();
    orders.push({
      id: doc.id,
      ...data,
    } as Order);
    logger.debug(`Debug from getOrders: ${orders}`);
  }
  logger.info("Info from getOrders: OK");

  return orders;
}

//  getAllByToken

export async function getOrdersByStartup(startupId: string): Promise<Order[]> {
  const snapshot = await orderCollection.where("startup_id", "==", startupId)
    .get();
  if (snapshot.empty) {
    logger.error(
      "Error from getOrdersByStartup: Falha ao buscar ordens de startup"
    );
    throw new HttpsError("data-loss", "Falha ao buscar ordens de startup");
  }

  const orders: Order[] = [];

  for (const doc of snapshot.docs) {
    const data = doc.data();
    orders.push({
      id: doc.id,
      ...data,
    } as Order);
    logger.debug(`Debug from getOrdersByStartup: ${orders}`);
  }
  logger.info("Info from getOrdersByStartup: OK");

  return orders;
}

//  getAllByUser

export async function getOrdersByUser(userId: string): Promise<Order[]> {
  const snapshot = await db
    .collection("orders")
    .where("user_id", "==", userId)
    .get();
  if (snapshot.empty) {
    logger.error(
      "Error from getOrdersByUser: Falha ao buscar ordens de usuário"
    );
    throw new HttpsError("data-loss", "Falha ao buscar ordens de usuário");
  }

  const orders: Order[] = [];

  for (const doc of snapshot.docs) {
    const data = doc.data();
    orders.push({
      id: doc.id,
      ...data,
    } as Order);
    logger.debug(`Debug from getOrdersByUser: ${orders}`);
  }
  logger.info("Info from getOrdersByUser: OK");

  return orders;
}

//  getAllByUserAndStartup

export async function getOrdersByUserAndStartup(
  userId: string,
  startupId: string,
): Promise<Order[]> {
  const snapshot = await orderCollection
    .where("user_id", "==", userId)
    .where("startup_id", "==", startupId)
    .get();
  if (snapshot.empty) {
    logger.error(
      "Error from getOrdersByUserAndStartup: " +
      "Falha ao buscar ordens de usuário na startup"
    );
    throw new HttpsError(
      "data-loss", "Falha ao buscar ordens de usuário na startup"
    );
  }

  const orders: Order[] = [];

  for (const doc of snapshot.docs) {
    const data = doc.data();
    orders.push({
      id: doc.id,
      ...data,
    } as Order);
    logger.debug(`Debug from getOrdersByUserAndStartup: ${orders}`);
  }
  logger.info("Info from getOrdersByUserAndStartup: OK");

  return orders;
}


//  getById

//  addOrder
// Argumento: Order, ou argumento
export async function createOrder(
  price: number,
  quantity: number,
  startupId: string,
  type: OrderType,
  tokenSymbol: string,
  userId: string): Promise<DocumentReference<DocumentData>> {
  const data: CreateOrderDTO = {
    price: price,
    quantity: quantity,
    quantity_filled: 0,
    startup_id: startupId,
    status: OrderStatus.open,
    token_symbol: tokenSymbol,
    type: type,
    user_id: userId,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  };
  return await orderCollection.add(data);
}


//  updateOrder

export async function updateOrder(
  orderId: string,
  quantityFilledNow?: number,
  status?: OrderStatus,
): Promise<void> {
  try {
    const docRef = orderCollection.doc(orderId);

    if (status === undefined && quantityFilledNow === undefined) {
      throw new Error(
        "invalid-argument: Nenhuma instrução foi passada como argumento",
      );
    }

    // Cancellation can be applied immediately without a transaction
    if (status && status === OrderStatus.cancelled) {
      await docRef.update({
        status: OrderStatus.cancelled,
        updatedAt: Timestamp.now(),
      });
      return;
    }

    // Use a transaction to avoid race conditions when updating quantity_filled
    await db.runTransaction(async (tx) => {
      const doc = await tx.get(docRef);
      if (!doc.exists) {
        throw new Error(
          "not-found: A ordem não foi encontrada no banco de dados",
        );
      }


      const orderData = doc.data() as CreateOrderDTO;
      if (orderData.status == OrderStatus.cancelled ||
        orderData.status == OrderStatus.filled) {
        throw new Error(
          "invalid-argument: Esta ordem ja foi fechada",
        );
      }
      const newFilled = orderData.quantity_filled + (quantityFilledNow ?? 0);

      if (newFilled > orderData.quantity) {
        throw new Error(
          "invalid-argument: O número de tokens comprados agora excede o limite disponível",
        );
      }

      // Auto-determine status based on quantity if not explicitly provided
      let newStatus: OrderStatus;
      if (newFilled === orderData.quantity) {
        newStatus = OrderStatus.filled;
      } else {
        newStatus = OrderStatus.partially;
      }

      tx.update(docRef, {
        status: newStatus,
        quantity_filled: newFilled,
        updatedAt: Timestamp.now(),
      });
    });
  } catch (e: unknown) {
    logger.error("Error in updateOrder:", e);

    if (e instanceof Error) {
      throw new HttpsError("failed-precondition", e.message);
    }

    throw new HttpsError("internal", "Erro desconhecido ao atualizar ordem");
  }
}
