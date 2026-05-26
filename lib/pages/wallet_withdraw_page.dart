import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/utils/numberformatter_service.dart';
import 'package:frontend/services/portfolio_refresh_service.dart';
import 'package:frontend/services/wallet_services.dart';

class WalletWithdrawPage extends StatefulWidget {
  const WalletWithdrawPage({super.key});

  @override
  State<WalletWithdrawPage> createState() => _WalletWithdrawPageState();
}

class _WalletWithdrawPageState extends State<WalletWithdrawPage> {
  final controller = TextEditingController();
  bool _isEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    // Para Atualizar o texto em baixo automaticamente
    super.initState();
    controller.addListener(() {
      setState(() {
        _isEnabled = (CurrencyFormatter.getNumericValue() >= 1.00);
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SACAR')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyFormatter.brl,
              ],
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'R\$ 0,00',
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            CurrencyFormatter.getNumericValue() < 1
                ? const Text(
                    'O valor mínimo de saque é de R\$ 1,00',
                    style: TextStyle(color: Colors.red),
                  )
                : const SizedBox(),
            const SizedBox(height: 32),
            _isEnabled
                ? Text(
                    'Sacando: ${moneyFormatter.format(CurrencyFormatter.getNumericValue())} da sua carteira',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : const SizedBox(height: 0),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: !_isEnabled || _isLoading
                  ? null
                  : () async {
                      setState(() {
                        _isLoading = true;
                      });

                      final result = await callWalletWithdraw(
                        CurrencyFormatter.getNumericValue().toString(),
                      );

                      if (!mounted) return;

                      if (result != null) {
                        requestPortfolioRefresh();
                        Navigator.of(context).pop(result);
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Não foi possível sacar.'),
                        ),
                      );

                      setState(() => _isLoading = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEnabled
                    ? Colors.indigo
                    : Colors.grey.shade400,
              ),
              child: const Text('SACAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
