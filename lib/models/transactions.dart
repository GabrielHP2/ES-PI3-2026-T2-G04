import 'package:cloud_firestore/cloud_firestore.dart';

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
      amountBRL: (map['amountBRL'] as num).toDouble(),
      createdAt: _parseTimestamp(map['createdAt']) as Timestamp,
      description: map['description'] as String,
      tradeId: map['tradeId'] as String?,
      type: TransactionType.values.byName(map['type'] as String),
      userId: map['userId'] as String,
    );
  }
}

Timestamp _parseTimestamp(dynamic value) {
  if (value is Timestamp) return value;
  if (value is Map) {
    final seconds = (value['_seconds'] ?? value['seconds']) as int;
    final nanoseconds =
        (value['_nanoseconds'] ?? value['nanoseconds'] ?? 0) as int;
    return Timestamp(seconds, nanoseconds);
  }
  return Timestamp.now();
}
