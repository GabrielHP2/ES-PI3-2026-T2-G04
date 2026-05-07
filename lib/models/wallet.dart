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
