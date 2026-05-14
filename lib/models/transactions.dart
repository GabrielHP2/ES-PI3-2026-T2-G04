import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/decimal_service.dart';

enum TransactionType { expense, income }

class TransactionModel {
  final double amountBRL;
  final Timestamp createdAt;
  final String description;
  final String? tradeId;
  final TransactionType type;
  final String userId;

  const TransactionModel({
    required this.amountBRL,
    required this.createdAt,
    required this.description,
    this.tradeId,
    required this.type,
    required this.userId,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      // CORREÇÃO: Usando a função auxiliar em vez do cast direto 'as num'
      amountBRL: toDouble(map['amountBRL'] ?? map['amount_brl']),
      createdAt: _parseTimestamp(map['createdAt']),
      description: map['description'] as String? ?? '',
      tradeId: map['tradeId'] as String?,
      type: TransactionType.values.byName(map['type'] as String),
      userId: map['userId'] as String? ?? '',
    );
  }
}

Timestamp _parseTimestamp(dynamic value) {
  if (value is Timestamp) return value;
  if (value is Map) {
    final seconds = (value['_seconds'] ?? value['seconds'] ?? 0) as int;
    final nanoseconds =
        (value['_nanoseconds'] ?? value['nanoseconds'] ?? 0) as int;
    return Timestamp(seconds, nanoseconds);
  }
  return Timestamp.now();
}
