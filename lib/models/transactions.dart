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
}
