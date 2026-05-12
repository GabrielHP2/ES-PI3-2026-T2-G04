import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { open, partially, filled, cancelled }

enum OrderType { buy, sell }

extension OrderTypeX on OrderType {
  String get backendValue => name;
  String get label => this == OrderType.buy ? 'Compra' : 'Venda';
}

extension OrderStatusX on OrderStatus {
  String get backendValue => name;
  String get label {
    switch (this) {
      case OrderStatus.open:
        return 'Aberta';
      case OrderStatus.partially:
        return 'Parcial';
      case OrderStatus.filled:
        return 'Executada';
      case OrderStatus.cancelled:
        return 'Cancelada';
    }
  }

  static OrderStatus fromBackend(dynamic value) {
    final raw = (value ?? '').toString().toLowerCase().trim();
    return OrderStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => OrderStatus.open,
    );
  }
}

class CreateOrderDTO {
  final double price;
  final int quantity;
  final String startupId;
  final OrderType type;
  final String tokenSymbol;

  const CreateOrderDTO({
    required this.price,
    required this.quantity,
    required this.startupId,
    required this.type,
    required this.tokenSymbol,
  });

  Map<String, dynamic> toBackendMap() {
    return {
      'price': price,
      'quantity': quantity,
      'startup_id': startupId,
      'type': type.backendValue,
      'token_symbol': tokenSymbol,
    };
  }
}

class OrderSubmissionResult {
  final bool success;
  final String message;
  final String? orderId;
  final OrderStatus? status;

  const OrderSubmissionResult({
    required this.success,
    required this.message,
    this.orderId,
    this.status,
  });
}

class OrderModel {
  final String id;
  final double price;
  final int quantity;
  final int quantityFilled;
  final String startupId;
  final OrderStatus status;
  final String tokenSymbol;
  final OrderType type;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const OrderModel({
    required this.id,
    required this.price,
    required this.quantity,
    required this.quantityFilled,
    required this.startupId,
    required this.status,
    required this.tokenSymbol,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  static Timestamp? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value;
    if (value is DateTime) return Timestamp.fromDate(value);
    if (value is String) {
      try {
        final dt = DateTime.parse(value);
        return Timestamp.fromDate(dt);
      } catch (_) {
        return null;
      }
    }
    if (value is Map) {
      try {
        final seconds = (value['_seconds'] as num?)?.toInt();
        final nanos = (value['_nanoseconds'] as num?)?.toInt();
        if (seconds != null) {
          return Timestamp(seconds, nanos ?? 0);
        }
      } catch (_) {}
    }
    return null;
  }

  factory OrderModel.fromBackendMap(Map<String, dynamic> map) {
    final rawType = (map['type'] ?? '').toString().toLowerCase().trim();
    final type = rawType == 'sell' ? OrderType.sell : OrderType.buy;

    return OrderModel(
      id: (map['id'] ?? '').toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      quantityFilled: (map['quantity_filled'] as num?)?.toInt() ?? 0,
      startupId: (map['startup_id'] ?? '').toString(),
      status: OrderStatusX.fromBackend(map['status']),
      tokenSymbol: (map['token_symbol'] ?? '').toString(),
      type: type,
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  OrderModel copyWith({
    String? id,
    double? price,
    int? quantity,
    int? quantityFilled,
    String? startupId,
    OrderStatus? status,
    String? tokenSymbol,
    OrderType? type,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      quantityFilled: quantityFilled ?? this.quantityFilled,
      startupId: startupId ?? this.startupId,
      status: status ?? this.status,
      tokenSymbol: tokenSymbol ?? this.tokenSymbol,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ConfirmOrderModel {
  final String startupId;
  final String startupName;
  final String tokenSymbol;
  final OrderType type;
  final int quantity;
  final double price;
  final double userBalance;
  final int userTokenBalance;
  final double userAvgPrice;

  const ConfirmOrderModel({
    required this.startupId,
    required this.startupName,
    required this.tokenSymbol,
    required this.type,
    required this.quantity,
    required this.price,
    required this.userBalance,
    required this.userTokenBalance,
    required this.userAvgPrice,
  });

  double get totalValue => price * quantity;

  String get typeLabel => type.label;

  double get balanceAfter => type == OrderType.buy
      ? userBalance - totalValue
      : userBalance + totalValue;

  int get tokenBalanceAfter => type == OrderType.buy
      ? userTokenBalance + quantity
      : userTokenBalance - quantity;

  double get avgPriceAfter {
    if (type == OrderType.sell) return userAvgPrice;
    final totalTokens = tokenBalanceAfter;
    if (totalTokens <= 0) return 0;
    final currentTotalCost = userAvgPrice * userTokenBalance;
    final newCost = price * quantity;
    return (currentTotalCost + newCost) / totalTokens;
  }

  CreateOrderDTO toCreateOrderDTO() {
    return CreateOrderDTO(
      price: price,
      quantity: quantity,
      startupId: startupId,
      type: type,
      tokenSymbol: tokenSymbol,
    );
  }
}
