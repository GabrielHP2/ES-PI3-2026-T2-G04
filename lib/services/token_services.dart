// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import 'package:cloud_functions/cloud_functions.dart';
import 'package:frontend/models/order_model.dart';
import 'package:frontend/models/token.dart';

final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
  region: 'southamerica-east1',
);

Token _mapToken(dynamic data) {
  final map = Map<String, dynamic>.from(data as Map);
  return Token.fromBackendMap(map);
}

List<Token> _mapTokenList(dynamic data) {
  try {
    if (data is Map<String, dynamic> && data['startups'] is List<dynamic>) {
      final startups = data['startups'] as List<dynamic>;
      return startups.map(_mapToken).toList();
    }

    if (data is List<dynamic>) {
      return data.map(_mapToken).toList();
    }

    // fallback: empty
    return const [];
  } catch (e) {
    return const [];
  }
}

Future<List<Token>> buscarTokens() async {
  try {
    final callable = _functions.httpsCallable('tokensCatalog');
    final result = await callable.call();
    return _mapTokenList(result.data);
  } catch (e) {
    return [];
  }
}

Future<Token?> buscarTokenPorStartupId(String startupId) async {
  try {
    final callable = _functions.httpsCallable('getTokenByStartupId');
    final result = await callable.call({'id': startupId});
    return _mapToken(Map<String, dynamic>.from(result.data as Map));
  } catch (_) {
    return null;
  }
}

Future<OrderSubmissionResult> placeOrder(CreateOrderDTO dto) async {
  try {
    final callable = _functions.httpsCallable('placeOrder');
    final result = await callable.call(dto.toBackendMap());
    final data = Map<String, dynamic>.from(result.data as Map);
    return OrderSubmissionResult(
      success: true,
      message: (data['message'] ?? 'Ordem criada com sucesso').toString(),
      orderId: data['orderId']?.toString(),
      status: OrderStatus.open,
    );
  } on FirebaseFunctionsException catch (e) {
    return OrderSubmissionResult(
      success: false,
      message: e.message ?? 'Falha ao criar ordem',
    );
  } catch (_) {
    return const OrderSubmissionResult(
      success: false,
      message: 'Falha ao criar ordem',
    );
  }
}

Future<List<OrderModel>> listOrders() async {
  try {
    final callable = _functions.httpsCallable('listOrdersCallable');
    final result = await callable.call();
    final data = Map<String, dynamic>.from(result.data as Map);
    final orders = data['orders'] as List<dynamic>? ?? const [];
    return orders
        .map(
          (e) => OrderModel.fromBackendMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  } catch (_) {
    return [];
  }
}

Future<List<OrderModel>> listOrdersByToken(String startupId) async {
  try {
    final callable = _functions.httpsCallable('listOrdersByToken');
    final result = await callable.call({'startupId': startupId});
    final data = Map<String, dynamic>.from(result.data as Map);
    final orders = data['orders'] as List<dynamic>? ?? const [];
    return orders
        .map(
          (e) => OrderModel.fromBackendMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  } catch (_) {
    return [];
  }
}

Future<List<OrderModel>> callGetOrdersByStartupByType(
  String startupId,
  OrderType type,
) async {
  try {
    final callable = _functions.httpsCallable('getOrdersByStartupAndType');
    final result = await callable.call({
      'startupId': startupId,
      'type': type.backendValue,
    });
    final data = result.data as Map<String, dynamic>;
    final orders = (data['orders'] as List<dynamic>? ?? [])
        .map(
          (d) => OrderModel.fromBackendMap(Map<String, dynamic>.from(d as Map)),
        )
        .toList();

    final mergedOrders = _mergeOrdersByPrice(orders);
    return _sortOrdersByPrice(mergedOrders, type);
  } on FirebaseFunctionsException {
    return [];
  } catch (e) {
    return [];
  }
}

List<OrderModel> _mergeOrdersByPrice(List<OrderModel> orders) {
  final Map<double, OrderModel> priceMap = {};

  for (final order in orders) {
    if (priceMap.containsKey(order.price)) {
      // Soma a quantidade na ordem existente
      final existing = priceMap[order.price]!;
      priceMap[order.price] = existing.copyWith(
        quantity: existing.quantity + order.quantity,
      );
    } else {
      priceMap[order.price] = order;
    }
  }

  return priceMap.values.toList();
}

List<OrderModel> _sortOrdersByPrice(List<OrderModel> orders, OrderType type) {
  final sortedOrders = List<OrderModel>.from(orders)
    ..sort((a, b) {
      if (type == OrderType.buy) {
        return b.price.compareTo(a.price);
      }
      return a.price.compareTo(b.price);
    });

  return sortedOrders;
}

Future<OrderSubmissionResult> callCancelOrder(String orderId) async {
  try {
    final callable = _functions.httpsCallable('cancelOrderCallable');
    final result = await callable.call({'orderId': orderId});
    final data = Map<String, dynamic>.from(result.data as Map);
    return OrderSubmissionResult(
      success: true,
      message: (data['message'] ?? 'Ordem deletada com sucesso').toString(),
      orderId: data['orderId']?.toString(),
      status: OrderStatus.cancelled,
    );
  } on FirebaseFunctionsException catch (e) {
    return OrderSubmissionResult(
      success: false,
      message: e.message ?? 'Falha ao deletar ordem',
    );
  } catch (_) {
    return const OrderSubmissionResult(
      success: false,
      message: 'Falha ao deletar ordem',
    );
  }
}
