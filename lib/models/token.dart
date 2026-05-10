import 'package:cloud_firestore/cloud_firestore.dart';

class TokenPricePoint {
  final String id;
  final double price;
  final int? quantity;
  final Timestamp executedAt;

  const TokenPricePoint({
    required this.id,
    required this.price,
    required this.executedAt,
    required this.quantity,
  });

  static Timestamp _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value;
    if (value is DateTime) return Timestamp.fromDate(value);
    if (value is Map<String, dynamic>) {
      final seconds = value['_seconds'];
      if (seconds is int) {
        final nanos = (value['_nanoseconds'] as int?) ?? 0;
        return Timestamp(seconds, nanos);
      }
    }
    return Timestamp.now();
  }

  factory TokenPricePoint.fromMap(Map<String, dynamic> map) {
    return TokenPricePoint(
      id: (map['id'] ?? '').toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt(),
      executedAt: _parseTimestamp(map['executed_at']),
    );
  }
}

class Token {
  final String startupId;
  final String nome;
  final String tokenSymbol;
  final double precoAtual;
  final double currentRaised;
  final List<TokenPricePoint> priceHistory;
  final double variacao;

  const Token({
    required this.startupId,
    required this.nome,
    required this.tokenSymbol,
    required this.precoAtual,
    required this.currentRaised,
    required this.priceHistory,
    required this.variacao,
  });

  List<double> get historicoPrecos =>
      priceHistory.map((p) => p.price).toList(growable: false);

  factory Token.fromBackendMap(Map<String, dynamic> map) {
    final rawHistory = map['price_history'] as List<dynamic>? ?? const [];
    final history = rawHistory
        .map((e) => TokenPricePoint.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.executedAt.compareTo(b.executedAt));

    final currentPrice = (map['last_price'] as num?)?.toDouble() ?? 0;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    TokenPricePoint? previousDayLast;
    for (final p in history) {
      if (p.executedAt.toDate().isBefore(startOfDay)) {
        previousDayLast = p;
      }
    }

    final base = previousDayLast?.price ?? currentPrice;
    final variacao = base > 0 ? ((currentPrice - base) / base) * 100 : 0.0;

    return Token(
      startupId: (map['id'] ?? map['startup_id'] ?? '').toString(),
      nome: (map['name'] ?? map['nome'] ?? '').toString(),
      tokenSymbol: (map['token_symbol'] ?? '').toString(),
      precoAtual: currentPrice,
      currentRaised: (map['current_raised'] as num?)?.toDouble() ?? 0,
      priceHistory: history,
      variacao: variacao,
    );
  }
}