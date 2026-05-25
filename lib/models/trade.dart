// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

class Trade {
  final String id;
  final String buyOrderId;
  final String sellOrderId;
  final double price;
  final int qtd;
  final DateTime executedAt;
  final String buyerId;
  final String sellerId;
  final String startupId;
  final String tokenSymbol;

  Trade({
    required this.id,
    required this.buyOrderId,
    required this.sellOrderId,
    required this.price,
    required this.qtd,
    required this.executedAt,
    required this.buyerId,
    required this.sellerId,
    required this.startupId,
    required this.tokenSymbol,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'] as String,
      buyOrderId: json['buyOrderId'] as String,
      sellOrderId: json['sellOrderId'] as String,
      price: double.parse(json['price'].toString()),
      qtd: json['qty'] as int,
      executedAt: _parseTimestamp(json['executedAt']),
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      startupId: json['startup_id'] as String,
      tokenSymbol: json['token_symbol'] as String,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is String) return DateTime.parse(value).toLocal();
    if (value is Map) {
      final seconds = (value['seconds'] ?? value['_seconds'] ?? 0) as int;
      final nanos = (value['nanos'] ?? value['nanoseconds'] ?? value['_nanoseconds'] ?? 0) as int;
      return DateTime.fromMicrosecondsSinceEpoch(
        seconds * 1000000 + nanos ~/ 1000,
        isUtc: true,
      ).toLocal();
    }
    return DateTime.now();
  }
}