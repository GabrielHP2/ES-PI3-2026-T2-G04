import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';

enum PaymentMethods { debit, credit, pix, none }

class WalletDepositPage extends StatefulWidget {
  const WalletDepositPage({super.key});

  @override
  State<WalletDepositPage> createState() => _WalletDepositPageState();
}

class _WalletDepositPageState extends State<WalletDepositPage> {
  final controller = MoneyMaskedTextController(
    //Para fazer o input da quantidade de dinheiro estilo pix de bancos
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  PaymentMethods _paymentMethod = PaymentMethods.none;
  bool _isValid = false;
  bool _isEnabled = false;

  @override
  void initState() {
    // Para Atualizar o texto em baixo automaticamente
    super.initState();
    controller.addListener(() {
      setState(() {
        _isEnabled = (_isValid && controller.numberValue > 1.00);
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
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 40, fontWeight: .bold),
              decoration: InputDecoration(
                hintText: 'R\$ 0,00',
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            controller.numberValue < 1
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
                    _isEnabled = (_isValid && controller.numberValue > 1.00);
                  });
                }
              },
            ),
            SizedBox(height: 16),
            _isEnabled
                ? Text(
                    'Depositando: R\$ ${controller.numberValue} na sua carteira via ${_paymentMethod == PaymentMethods.debit
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
              onPressed: () {
                //Adicionar saldo na carteira do usuário
                !_isEnabled ? null : Navigator.of(context).pop();
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: _isEnabled
                    ? Colors.indigo
                    : Colors.grey.shade400,
              ),
              child: Text('DEPOSITAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
