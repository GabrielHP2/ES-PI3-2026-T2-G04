import 'package:flutter/material.dart';
import 'package:frontend/components/transaction_card.dart';
import 'package:frontend/models/transactions.dart';
import 'package:frontend/pages/wallet_deposit_page.dart';
import 'package:frontend/pages/wallet_withdraw_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final TransactionModel demoTransaction = TransactionModel(
    amountBRL: 200,
    createdAt: Timestamp.now(),
    description: 'Compra de tokens \$FNOVA',
    type: TransactionType.expense,
    userId: 'jp',
  );
  final TransactionModel demoTransaction1 = TransactionModel(
    amountBRL: 40000,
    createdAt: Timestamp.now(),
    description: 'Venda de tokens \$FNOVA',
    type: TransactionType.income,
    userId: 'jp',
  );
  final List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _transactions.add(demoTransaction);
    _transactions.add(demoTransaction1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CARTEIRA')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('SALDO DISPONÍVEL'),
                  Text(
                    'R\$150,00',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsetsGeometry.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('SALDO BLOQUEADO'),
                  Text('(ORDENS PENDENTES)', style: TextStyle(fontSize: 11)),
                  Text(
                    'R\$50,00',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WalletDepositPage(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                  child: const Text(
                    'DEPOSITAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WalletWithdrawPage(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                  ),
                  child: const Text(
                    '    SACAR    ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Text(
                'Histórico de transações',
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
            Divider(),
            SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _transactions.length,
                padding: EdgeInsets.zero,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    TransactionCard(transaction: _transactions[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
