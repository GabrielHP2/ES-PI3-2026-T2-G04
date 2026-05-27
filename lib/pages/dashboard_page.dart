import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/balance_header.dart';
import 'package:frontend/components/card_container.dart';
import 'package:frontend/components/owned_tokens.dart';
import 'package:frontend/components/trade_history.dart';
import 'package:frontend/components/user_order_card.dart';
import 'package:frontend/utils/numberformatter_service.dart';
import 'package:frontend/services/portfolio_refresh_service.dart';
import 'package:frontend/services/wallet_services.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Decimal? _walletValue;
  bool _isLoading = true;

  void _handlePortfolioRefresh() {
    _fetchWalletValue();
  }

  Future<void> _fetchWalletValue() async {
    setState(() {
      _isLoading = true;
    });
    final result = await getWalletValue();
    if (!mounted) return;
    setState(() {
      _walletValue = result;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    portfolioRefreshNotifier.addListener(_handlePortfolioRefresh);
    _fetchWalletValue();
  }

  @override
  void dispose() {
    portfolioRefreshNotifier.removeListener(_handlePortfolioRefresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchWalletValue(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      BalanceHeader(),
                      CardContainer(
                        child: Column(
                          crossAxisAlignment: .center,
                          children: [
                            Text(
                              'Valor investido em tokens',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 18,
                                fontWeight: .w400,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              formatMoney(
                                _walletValue?.toDouble() ?? 0.0,
                              ),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: .bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      sectionSeparator('Seus Investimentos'),
                      OwnedTokensList(),
                      sectionSeparator('Suas Ordens Abertas'),
                      UserOrderList(),
                      sectionSeparator('Histórico de Trades'),
                      TradeHistory(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget sectionSeparator(String title) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Divider(),
      ],
    );
  }
}
