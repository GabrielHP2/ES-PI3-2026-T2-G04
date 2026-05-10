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
  final startups =
      (data as Map<String, dynamic>)['startups'] as List<dynamic>? ?? const [];
  return startups.map(_mapToken).toList();
}

Future<List<Token>> buscarTokens() async {
  try {
    final callable = _functions.httpsCallable('tokensCatalog');
    final result = await callable.call();
    return _mapTokenList(Map<String, dynamic>.from(result.data as Map));
  } catch (_) {
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
    final callable = _functions.httpsCallable('listOrders');
    final result = await callable.call();
    final data = Map<String, dynamic>.from(result.data as Map);
    final orders = data['orders'] as List<dynamic>? ?? const [];
    return orders
        .map((e) => OrderModel.fromBackendMap(Map<String, dynamic>.from(e as Map)))
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
        .map((e) => OrderModel.fromBackendMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  } catch (_) {
    return [];
  }
}