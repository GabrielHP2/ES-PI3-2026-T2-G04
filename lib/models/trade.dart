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
      price: (json['price'] as num).toDouble(),
      qtd: json['qty'] as int,
      executedAt: DateTime.parse(json['executedAt'] as String),
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      startupId: json['startup_id'] as String,
      tokenSymbol: json['token_symbol'] as String,
    );
  }
}