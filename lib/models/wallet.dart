// João Pedro Panza Mainieri - 25006642;
import 'package:frontend/utils/decimal_utils.dart';

enum PaymentType { credit, debit, pix, none }

class WalletBalance {
  final double availableBalance;
  final double blockedBalance;

  WalletBalance({required this.availableBalance, required this.blockedBalance});

  factory WalletBalance.fromMap(Map<String, dynamic> map) {
    return WalletBalance(
      availableBalance: double.parse(map['availableBalance']),
      blockedBalance: double.parse(map['blockedBalance']),
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
      availableBalance: toDouble(map['availableBalance']),
      blockedBalance: toDouble(map['blockedBalance']),
      holdings:
          (map['holdings'] as List?)
              ?.map((x) => Holding.fromMap(Map<String, dynamic>.from(x)))
              .toList() ??
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
      avgPrice: toDouble(map['avg_price']),
      blockedTokenBalance: toDouble(map['blocked_token_balance']),
      startupId: map['startupId'] ?? map['startup_id'] ?? '',
      tokenBalance: toDouble(map['token_balance']),
      tokenSymbol: map['token_symbol'] ?? '',
    );
  }
}
