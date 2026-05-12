import { db } from "../../startups/shared/firebase";
import {
  CreateOrderDTO,
  Order,
  OrderStatus,
  OrderType,
} from "../types/orderType";
import { logger } from "firebase-functions/v2";
import { HttpsError } from "firebase-functions/v2/https";
import {
  DocumentData,
  DocumentReference,
  Timestamp,
} from "firebase-admin/firestore";

const orderCollection = db.collection("orders");

//  getAll
export async function getOrders(): Promise<Order[]> {
  const snapshot = await orderCollection.get();
  if (snapshot.empty) return [];
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }) as Order);
}

//  getAllByToken

export async function getOrdersByStartup(startupId: string): Promise<Order[]> {
  const snapshot = await orderCollection
    .where("startup_id", "==", startupId)
    .get();
  if (snapshot.empty) return [];
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }) as Order);
}

export async function getOrdersByStartupAndType(
  startupId: string,
  type: OrderType,
): Promise<Order[]> {
  const snapshot = await orderCollection
    .where("startup_id", "==", startupId)
    .where("type", "==", type)
    .where("status", "in", ["open", "partially"])
    .get();

  if (snapshot.empty) return [];

  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }) as Order);
}

//  getAllByUser

export async function getOrdersByUser(userId: string): Promise<Order[]> {
  const [snapshotBySnake, snapshotByCamel] = await Promise.all([
    orderCollection.where("user_id", "==", userId).get(),
    orderCollection.where("userId", "==", userId).get(),
  ]);

  const ordersMap = new Map<string, Order>();

  for (const doc of [...snapshotBySnake.docs, ...snapshotByCamel.docs]) {
    ordersMap.set(doc.id, { id: doc.id, ...doc.data() } as Order);
  }

  return [...ordersMap.values()];
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
  if (snapshot.empty) return [];
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }) as Order);
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
  userId: string,
): Promise<DocumentReference<DocumentData>> {
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

// cancelOrder
export async function cancelOrder(orderId: string): Promise<void> {
  try {
    const docRef = orderCollection.doc(orderId);

    await db.runTransaction(async (tx) => {
      const doc = await tx.get(docRef);

      if (!doc.exists) {
        throw new HttpsError("not-found", "Ordem não encontrada");
      }

      const orderData = doc.data() as CreateOrderDTO;

      if (
        orderData.status === OrderStatus.cancelled ||
        orderData.status === OrderStatus.filled
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Esta ordem já foi fechada",
        );
      }

      const uid = orderData.user_id!;
      const walletRef = db.collection("wallets").doc(uid);
      const walletSnap = await tx.get(walletRef);

      if (!walletSnap.exists) {
        throw new HttpsError("not-found", "Carteira não encontrada");
      }

      const wallet = walletSnap.data()!;
      const remaining = orderData.quantity - orderData.quantity_filled;

      if (remaining < 0) {
        throw new HttpsError(
          "failed-precondition",
          "Ordem em estado inconsistente",
        );
      }

      if (orderData.type === OrderType.buy) {
        const refund = remaining * orderData.price;

        tx.update(walletRef, {
          availableBalance: wallet.availableBalance + refund,
          blockedBalance: wallet.blockedBalance - refund,
        });
      }

      if (orderData.type === OrderType.sell) {
        const holdings: any[] = wallet.holdings ?? [];
        const holdingIndex = holdings.findIndex(
          (h: any) => h.startup_id === orderData.startup_id,
        );

        if (holdingIndex === -1) {
          throw new HttpsError("not-found", "Holding não encontrada");
        }

        const holding = holdings[holdingIndex];

        holdings[holdingIndex] = {
          ...holding,
          token_balance: holding.token_balance + remaining,
          blocked_token_balance: holding.blocked_token_balance - remaining,
        };

        tx.update(walletRef, { holdings });
      }

      tx.update(docRef, {
        status: OrderStatus.cancelled,
        updatedAt: Timestamp.now(),
      });
    });
  } catch (e: unknown) {
    logger.error("Error in cancelOrder:", e);
    if (e instanceof HttpsError) throw e;
    if (e instanceof Error)
      throw new HttpsError("failed-precondition", e.message);
    throw new HttpsError("internal", "Erro desconhecido ao cancelar ordem");
  }
}

// executeOrderExecution
export async function executeOrderExecution(
  orderId: string,
  quantityFilledNow: number,
): Promise<void> {
  try {
    if (quantityFilledNow <= 0) {
      throw new HttpsError(
        "invalid-argument",
        "A quantidade preenchida deve ser maior que zero",
      );
    }

    const docRef = orderCollection.doc(orderId);

    await db.runTransaction(async (tx) => {
      const doc = await tx.get(docRef);

      if (!doc.exists) {
        throw new HttpsError("not-found", "Ordem não encontrada");
      }

      const orderData = doc.data() as CreateOrderDTO;

      // Não permite preencher uma ordem já fechada
      if (
        orderData.status === OrderStatus.cancelled ||
        orderData.status === OrderStatus.filled
      ) {
        throw new HttpsError(
          "failed-precondition",
          "Esta ordem já foi fechada",
        );
      }

      const newFilled = orderData.quantity_filled + quantityFilledNow;

      if (newFilled > orderData.quantity) {
        throw new HttpsError(
          "invalid-argument",
          `Quantidade excede o limite: tentou preencher ${quantityFilledNow}, ` +
            `mas só restam ${orderData.quantity - orderData.quantity_filled} tokens`,
        );
      }

      // Se preencheu tudo → filled; senão → partially
      const newStatus =
        newFilled === orderData.quantity
          ? OrderStatus.filled
          : OrderStatus.partially;

      tx.update(docRef, {
        status: newStatus,
        quantity_filled: newFilled,
        updatedAt: Timestamp.now(),
      });
    });
  } catch (e: unknown) {
    logger.error("Error in executeOrderExecution:", e);
    if (e instanceof HttpsError) throw e;
    if (e instanceof Error)
      throw new HttpsError("failed-precondition", e.message);
    throw new HttpsError("internal", "Erro desconhecido ao executar ordem");
  }
}
