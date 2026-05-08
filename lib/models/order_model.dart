enum OrderStatus { open, partially, filled, cancelled }

enum OrderType { buy, sell }

class ConfirmOrderModel {
  final double price;
  final int quantity;
  final String startupName;
  final double userBalance;
  final int userTokenBalance;
  final String tokenSymbol;
  final OrderType type;
  final String userName;
  final String userCpf;
  final double userAvgPrice;

  double get balanceAfter => type == OrderType.buy
      ? userBalance - totalValue
      : userBalance + totalValue;

  int get tokenBalanceAfter => type == OrderType.buy
      ? userTokenBalance + quantity
      : userTokenBalance - quantity;

  double get avgPriceAfter {
    final totalTokens = tokenBalanceAfter;
    if (totalTokens == 0) return 0;

    final currentTotalCost = userAvgPrice * userTokenBalance; // custo atual
    final newCost = price * quantity; // custo desta ordem

    return (currentTotalCost + newCost) / totalTokens;
  }

  ConfirmOrderModel({
    required this.price,
    required this.quantity,
    required this.startupName,
    required this.tokenSymbol,
    required this.type,
    required this.userName,
    required this.userCpf,
    required this.userBalance,
    required this.userTokenBalance,
    required this.userAvgPrice,
  });

  double get totalValue => price * quantity;

  String get typeLabel => type == OrderType.buy ? 'Compra' : 'Venda';
}
