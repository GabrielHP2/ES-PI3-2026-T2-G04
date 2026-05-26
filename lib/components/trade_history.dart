// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/utils/numberformatter_service.dart';
import '../models/trade.dart';
import '../services/trade_history_service.dart';

class TradeHistory extends StatefulWidget {
  const TradeHistory({super.key});

  @override
  State<TradeHistory> createState() => _TradeHistoryState();
}

class _TradeHistoryState extends State<TradeHistory> {
  late Future<List<Trade>> futureTrades;

  @override
  void initState() {
    super.initState();
    futureTrades = TradeHistoryService.fetchTrades();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trade>>(
      future: futureTrades,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Erro ao buscar histórico de trades'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma trade encontrada'));
        }
        final trades = snapshot.data!;
        final userId = FirebaseAuth.instance.currentUser?.uid;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trades.length,
          itemBuilder: (context, index) {
            final trade = trades[index];
            final isBuy = trade.buyerId == userId;
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              child: ListTile(
                dense: true,
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                leading: isBuy
                    ? const Icon(Icons.add, color: Colors.green)
                    : const Icon(Icons.remove, color: Colors.red),
                title: Text(
                  trade.tokenSymbol,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantidade: ${trade.qtd}'),
                    Text(
                      'Preço por Token: ${moneyFormatter.format(trade.price)}',
                    ),
                    Text(
                      'Executado em: ${trade.executedAt.day.toString().padLeft(2, '0')}/${trade.executedAt.month.toString().padLeft(2, '0')}/${trade.executedAt.year}',
                    ),
                  ],
                ),
                subtitleTextStyle: const TextStyle(color: Colors.black87),
                trailing: Text(
                  moneyFormatter.format(trade.price * trade.qtd),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
