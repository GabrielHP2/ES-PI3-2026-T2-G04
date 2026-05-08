class TransactionModel {
  final String id;
  final String startupName;
  final String ticker;
  final String type; // Compra ouu venda
  final int quantity;
  final double unitPrice;
  final double totalValue;
  final DateTime timestamp;
  final String investorName;
  final String investorCpf;

  TransactionModel({
    required this.id,
    required this.startupName,
    required this.ticker,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.totalValue,
    required this.timestamp,
    required this.investorName,
    required this.investorCpf,
  });

  //  Conversao o json da api do node
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      startupName: json['startupName'] ?? '',
      ticker: json['ticker'] ?? '',
      type: json['type'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalValue: (json['totalValue'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      investorName: json['investorName'] ?? '',
      investorCpf: json['investorCpf'] ?? '',
    );
  }
}