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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
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
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
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

  double get balanceAfter =>
      type == OrderType.buy ? userBalance - totalValue : userBalance + totalValue;

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