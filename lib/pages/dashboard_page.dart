import 'package:flutter/material.dart';
import 'package:frontend/components/balance_header.dart';
import 'package:frontend/services/numberformatter_service.dart';
import 'package:frontend/services/wallet_services.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double _walletValue = 0;
  bool _isLoading = true;

  Future<void> _fetchWalletValue() async {
    setState(() {
      _isLoading = true;
    });
    final result = await getWalletValue();
    setState(() {
      _walletValue = result;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchWalletValue();
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
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      BalanceHeader(),
                      _card(
                        Column(
                          crossAxisAlignment: .center,
                          children: [
                            Text(
                              'Valor da carteira',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 18,
                                fontWeight: .w400,
                              ),
                            ),
                            Text(
                              moneyFormatter.format(_walletValue),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: .bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      sectionSeparator('Tokens Comprados'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 1),
        ],
      ),
      child: child,
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
