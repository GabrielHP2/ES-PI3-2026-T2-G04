import 'package:flutter/material.dart';
import 'package:frontend/pages/wallet_page.dart';
import 'package:frontend/utils/numberformatter_service.dart';
import 'package:frontend/services/portfolio_refresh_service.dart';
import 'package:frontend/services/wallet_services.dart';

class BalanceHeader extends StatefulWidget {
  const BalanceHeader({super.key});
  @override
  State<BalanceHeader> createState() => _BalanceHeaderState();
}

class _BalanceHeaderState extends State<BalanceHeader> {
  bool _isLoading = true;
  double _saldoUsuario = 0;

  void _handlePortfolioRefresh() {
    _fetchData();
  }

  @override
  void initState() {
    super.initState();
    portfolioRefreshNotifier.addListener(_handlePortfolioRefresh);
    _fetchData();
  }

  @override
  void dispose() {
    portfolioRefreshNotifier.removeListener(_handlePortfolioRefresh);
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    final wallet = await callWalletBalance();
    if (!mounted) return;

    setState(() {
      _saldoUsuario = wallet?.availableBalance ?? 0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Saldo disponível:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                !_isLoading
                    ? Text(
                        formatMoney(_saldoUsuario),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : CircularProgressIndicator(),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WalletPage()),
                    );
                    await _fetchData();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.indigo),
                  ),
                  icon: const Icon(
                    Icons.credit_card,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }
}
