import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend/services/decimal_service.dart';
import 'package:frontend/services/variation_service.dart';

class TokenPricePoint {
  final String id;
  final Decimal price;
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
    if (value is Map) {
      // Firestore REST/serializado manda 'seconds'/'nanoseconds' (sem underscore)
      // Firestore SDK às vezes manda '_seconds'/'_nanoseconds' (com underscore)
      final seconds = (value['seconds'] ?? value['_seconds']) as int?;
      if (seconds != null) {
        final nanos =
            ((value['nanoseconds'] ?? value['_nanoseconds']) as int?) ?? 0;
        return Timestamp(seconds, nanos);
      }
    }
    return Timestamp.now();
  }

  /// Converte qualquer representação de preço (num, String) para Decimal
  /// sem perder precisão nem quebrar com notação científica de doubles.
  static Decimal _parsePrice(dynamic value) {
    if (value == null) return Decimal.zero;
    if (value is int) return Decimal.fromInt(value);
    // num/double: converte via toStringAsFixed para evitar representações
    // como "0.30000000000000004" que quebram Decimal.parse silenciosamente.
    if (value is double) {
      if (value.isNaN || value.isInfinite) return Decimal.zero;
      return toDecimal(value.toStringAsFixed(10));
    }
    // String: repassa direto para toDecimal
    return toDecimal(value.toString());
  }

  factory TokenPricePoint.fromMap(Map<String, dynamic> map) {
    return TokenPricePoint(
      id: (map['id'] ?? '').toString(),
      price: _parsePrice(map['price']),
      quantity: (map['quantity'] as num?)?.toInt(),
      executedAt: _parseTimestamp(map['executed_at']),
    );
  }
}

class Token {
  final String startupId;
  final String nome;
  final String tokenSymbol;
  final Decimal precoAtual;
  final Decimal currentRaised;
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

  List<Decimal> get historicoPrecos =>
      priceHistory.map((p) => p.price).toList(growable: false);

  static double _computeVariationFromSeries(
    List<TokenPricePoint> history,
    Decimal currentPrice,
  ) {
    if (currentPrice <= Decimal.zero) return 0.0;

    final valid = history.where((p) => p.price > Decimal.zero).toList()
      ..sort((a, b) => a.executedAt.compareTo(b.executedAt));

    if (valid.isEmpty) return 0.0;

    // FIX: usa o PRIMEIRO ponto como base (o mais antigo),
    // não o último — assim a variação reflete a valorização ao longo do tempo.
    final base = valid.first.price;

    if (base <= Decimal.zero) return 0.0;
    // Evita operações que retornem `Rational` — calcula em double com segurança
    final baseDouble = base.toDouble();
    final currentDouble = currentPrice.toDouble();
    // Delega ao utilitário compartilhado — mesma lógica usada na NegociacaoPage
    return calcularVariacaoPercentual(baseDouble, currentDouble);
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

    final backendLastPrice = toDecimal((map['last_price'] ?? '0').toString());
    final historyLastPrice = history.isNotEmpty
        ? history.last.price
        : Decimal.zero;
    final currentPrice = backendLastPrice > Decimal.zero
        ? backendLastPrice
        : historyLastPrice;

    final variation = _computeVariationFromSeries(history, currentPrice);

    return Token(
      startupId: (map['id'] ?? map['startup_id'] ?? '').toString(),
      nome: (map['name'] ?? map['nome'] ?? '').toString(),
      tokenSymbol: (map['token_symbol'] ?? '').toString(),
      precoAtual: currentPrice,
      currentRaised: toDecimal((map['current_raised'] ?? '0').toString()),
      priceHistory: history,
      variacao: variation,
    );
  }
}
