enum PaymentType { credit, debit, pix, none }

class WalletBalance {
  final double availableBalance;
  final double blockedBalance;

  WalletBalance({required this.availableBalance, required this.blockedBalance});

  factory WalletBalance.fromMap(Map<String, dynamic> map) {
    return WalletBalance(
      availableBalance: map['availableBalance'].toDouble(),
      blockedBalance: map['blockedBalance'].toDouble(),
    );
  }
}

class TokenWalletBalance {
  final double availableBalance;
  final double blockedBalance;
  final List<Holding> holdings;

  TokenWalletBalance({
    required this.availableBalance,
    required this.blockedBalance,
    required this.holdings,
  });

  factory TokenWalletBalance.fromMap(Map<String, dynamic> map) {
    return TokenWalletBalance(
      // Using .toDouble() or 'as num' to handle both int and double from JSON
      availableBalance: (map['availableBalance'] ?? 0.0).toDouble(),
      blockedBalance: (map['blockedBalance'] ?? 0.0).toDouble(),
      // Mapping the list of holdings
      holdings:
          ((map['holdings'] ?? map['Holdings']) as List<dynamic>?)?.map((x) {
            if (x is Map<String, dynamic>) {
              return Holding.fromMap(x);
            }
            return Holding.fromMap(Map<String, dynamic>.from(x as Map));
          }).toList() ??
          [],
    );
  }
}

class Holding {
  final double avgPrice;
  final double blockedTokenBalance;
  final String startupId;
  final double tokenBalance;
  final String tokenSymbol;

  Holding({
    required this.avgPrice,
    required this.blockedTokenBalance,
    required this.startupId,
    required this.tokenBalance,
    required this.tokenSymbol,
  });

  factory Holding.fromMap(Map<String, dynamic> map) {
    return Holding(
      avgPrice: (map['avgPrice'] ?? map['avg_price'] ?? 0.0).toDouble(),
      blockedTokenBalance:
          (map['blockedTokenBalance'] ?? map['blocked_token_balance'] ?? 0.0)
              .toDouble(),
      startupId: map['startupId'] ?? map['startup_id'] ?? '',
      tokenBalance: (map['tokenBalance'] ?? map['token_balance'] ?? 0.0)
          .toDouble(),
      tokenSymbol: map['tokenSymbol'] ?? map['token_symbol'] ?? '',
    );
  }
}
