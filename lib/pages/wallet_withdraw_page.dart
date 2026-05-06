import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:frontend/services/numberformatter_service.dart';

class WalletWithdrawPage extends StatefulWidget {
  const WalletWithdrawPage({super.key});

  @override
  State<WalletWithdrawPage> createState() => _WalletWithdrawPageState();
}

class _WalletWithdrawPageState extends State<WalletWithdrawPage> {
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
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'R\$ 0,00',
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            controller.numberValue < 1
                ? const Text(
                    'O valor mínimo de saque é de R\$ 1,00',
                    style: TextStyle(color: Colors.red),
                  )
                : const SizedBox(),
            const SizedBox(height: 32),
            _isEnabled
                ? Text(
                    'Sacando: ${moneyFormatter.format(controller.numberValue)} da sua carteira',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : const SizedBox(height: 0),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                !_isEnabled ? null : Navigator.of(context).pop();
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
