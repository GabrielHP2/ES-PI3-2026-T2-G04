// João Pedro Panza Mainieri - 25006642;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend/models/transactions.dart';
import 'package:frontend/utils/number_formatter.dart';

class TransactionCard extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  State<TransactionCard> createState() => _TrasactionCardState();
}

class _TrasactionCardState extends State<TransactionCard> {
  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final formattedCreatedAt = DateFormat(
      'dd/MM/yyyy HH:mm',
      'pt_BR',
    ).format(transaction.createdAt.toDate());

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
      child: Row(
        children: [
          Expanded(
            flex: 0,
            child: Center(
              child: transaction.type == TransactionType.expense
                  ? Icon(Icons.remove, color: Colors.red)
                  : Icon(Icons.add, color: Colors.green),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                //Text('Quantidade: 2', style: TextStyle(fontSize: 12)),
                /*Text(
                  'Preço por token: ${formatMoney(50.00)}',
                  style: TextStyle(fontSize: 12),
                ),
                */
                Text(formattedCreatedAt, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                formatMoney(transaction.amountBRL),
                style: TextStyle(
                  color: transaction.type == TransactionType.expense
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
