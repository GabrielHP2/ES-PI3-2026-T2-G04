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

  static double _computeVariationFromSeries(
    List<TokenPricePoint> history,
    double currentPrice,
  ) {
    if (currentPrice <= 0) return 0.0;

    final valid = history.where((p) => p.price > 0).toList()
      ..sort((a, b) => a.executedAt.compareTo(b.executedAt));

    if (valid.isEmpty) return 0.0;

    final last = valid.last;
    final sameAsLast = (last.price - currentPrice).abs() < 0.0000001;

    double? base;
    if (sameAsLast) {
      for (var i = valid.length - 2; i >= 0; i--) {
        if (valid[i].price > 0) {
          base = valid[i].price;
          break;
        }
      }
    } else {
      base = last.price;
    }

    if (base == null || base <= 0) return 0.0;
    return ((currentPrice - base) / base) * 100;
  }

  factory Token.fromBackendMap(Map<String, dynamic> map) {
    final rawHistory = map['price_history'] as List<dynamic>? ?? const [];
    final history =
        rawHistory
            .map(
              (e) =>
                  TokenPricePoint.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList()
          ..sort((a, b) => a.executedAt.compareTo(b.executedAt));

    final backendLastPrice = (map['last_price'] as num?)?.toDouble() ?? 0.0;
    final historyLastPrice = history.isNotEmpty ? history.last.price : 0.0;
    final currentPrice = backendLastPrice > 0
        ? backendLastPrice
        : historyLastPrice;

    final variation = _computeVariationFromSeries(history, currentPrice);

    return Token(
      startupId: (map['id'] ?? map['startup_id'] ?? '').toString(),
      nome: (map['name'] ?? map['nome'] ?? '').toString(),
      tokenSymbol: (map['token_symbol'] ?? '').toString(),
      precoAtual: currentPrice,
      currentRaised: (map['current_raised'] as num?)?.toDouble() ?? 0,
      priceHistory: history,
      variacao: variation,
    );
  }
}
