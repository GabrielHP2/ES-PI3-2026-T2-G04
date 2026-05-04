import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';

class WalletWithdrawPage extends StatefulWidget {
  const WalletWithdrawPage({super.key});

  @override
  State<WalletWithdrawPage> createState() => WalletWithdrawPageState();
}

class WalletWithdrawPageState extends State<WalletWithdrawPage> {
  final controller = MoneyMaskedTextController(
    //Para fazer o input da quantidade de dinheiro estilo pix de bancos
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  bool _isEnabled = false;

  @override
  void initState() {
    // Para Atualizar o texto em baixo automaticamente
    super.initState();
    controller.addListener(() {
      setState(() {
        _isEnabled = (controller.numberValue > 1.00);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SACAR')),
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
                    'O valor mínimo de saque é de R\$ 1,00',
                    style: TextStyle(color: Colors.red),
                  )
                : SizedBox(),
            SizedBox(height: 32),

            _isEnabled
                ? Text(
                    'Sacando: R\$ ${controller.numberValue} da sua carteira',
                    style: TextStyle(fontSize: 16, fontWeight: .w500),
                    //textAlign: .center,
                  )
                : SizedBox(height: 0),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                //Retirar saldo da carteira do usuário
                !_isEnabled ? null : Navigator.of(context).pop();
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: _isEnabled
                    ? Colors.indigo
                    : Colors.grey.shade400,
              ),
              child: Text('SACAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
