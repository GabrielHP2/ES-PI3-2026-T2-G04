import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/wallet.dart';
import 'package:frontend/services/portfolio_refresh_service.dart';
import 'package:frontend/services/wallet_services.dart';
import 'package:frontend/utils/currency_formatter.dart';

enum PaymentMethods { debit, credit, pix, none }

class WalletDepositPage extends StatefulWidget {
  const WalletDepositPage({super.key});

  @override
  State<WalletDepositPage> createState() => _WalletDepositPageState();
}

class _WalletDepositPageState extends State<WalletDepositPage> {
  final controller = TextEditingController();
  PaymentMethods _paymentMethod = PaymentMethods.none;
  bool _isValid = false;
  bool _isEnabled = false;
  bool _isSubmitting = false;

  PaymentType _toPaymentType(PaymentMethods method) {
    switch (method) {
      case PaymentMethods.credit:
        return PaymentType.credit;
      case PaymentMethods.debit:
        return PaymentType.debit;
      case PaymentMethods.pix:
        return PaymentType.pix;
      case PaymentMethods.none:
        return PaymentType.none;
    }
  }

  @override
  void initState() {
    // Para Atualizar o texto em baixo automaticamente
    super.initState();
    controller.addListener(() {
      setState(() {
        _isEnabled = (_isValid && CurrencyFormatter.parseValue(controller.text) >= 1.00);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DEPOSITAR')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          children: [
            TextField(
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyFormatter.brl,
              ],
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 40, fontWeight: .bold),
              decoration: InputDecoration(
                hintText: 'R\$ 0,00',
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            CurrencyFormatter.parseValue(controller.text) < 1
                ? Text(
                    'O valor mínimo de deposito é de R\$ 1,00',
                    style: TextStyle(color: Colors.red),
                  )
                : SizedBox(),
            SizedBox(height: 32),
            DropdownMenu(
              enableSearch: false,
              label: Text('Escolha o método de pagamento'),
              dropdownMenuEntries: <DropdownMenuEntry>[
                DropdownMenuEntry(
                  value: PaymentMethods.debit,
                  label: 'Débito',
                  leadingIcon: Icon(Icons.credit_card),
                ),
                DropdownMenuEntry(
                  value: PaymentMethods.credit,
                  label: 'Crédito',
                  leadingIcon: Icon(Icons.credit_card),
                ),
                DropdownMenuEntry(
                  value: PaymentMethods.pix,
                  label: 'Pix',
                  leadingIcon: Icon(Icons.pix),
                ),
              ],
              onSelected: (method) {
                if (method != null) {
                  setState(() {
                    _isValid = true;
                    _paymentMethod = method;
                    _isEnabled =
                        (_isValid &&
                        CurrencyFormatter.parseValue(controller.text) >= 1.00);
                  });
                }
              },
            ),
            SizedBox(height: 16),
            _isEnabled
                ? Text(
                    'Depositando: R\$ ${CurrencyFormatter.parseValue(controller.text)} na sua carteira via ${_paymentMethod == PaymentMethods.debit
                        ? 'débito'
                        : _paymentMethod == PaymentMethods.credit
                        ? 'crédito'
                        : 'pix'}',
                    style: TextStyle(fontSize: 16, fontWeight: .w500),
                    //textAlign: .center,
                  )
                : SizedBox(height: 0),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: (!_isEnabled || _isSubmitting)
                  ? null
                  : () async {
                      setState(() {
                        _isSubmitting = true;
                      });

                      final result = await callWalletDeposit(
                        CurrencyFormatter.parseValue(controller.text).toString(),
                        _toPaymentType(_paymentMethod),
                      );

                      if (!mounted) return;

                      if (result != null) {
                        requestPortfolioRefresh();
                        Navigator.of(context).pop(result);
                        return;
                      }

                      setState(() {
                        _isSubmitting = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Não foi possível depositar.'),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: (_isEnabled && !_isSubmitting)
                    ? Colors.indigo
                    : Colors.grey.shade400,
              ),
              child: Text(
                _isSubmitting ? 'DEPOSITANDO...' : 'DEPOSITAR',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
