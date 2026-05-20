// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import 'package:flutter/material.dart';
import 'package:frontend/services/numberformatter_service.dart';

class TradeHistory extends StatefulWidget {
  const TradeHistory({super.key});

  
  @override
  State<TradeHistory> createState() => _TradeHistoryState();
}

class _TradeHistoryState extends State<TradeHistory> {

  // vars pra teste
  final price = 12.99;
  final token = '\$FNOVA';
  final date = '20/02/2024';
  final qtd = 5;
  final isBuy = false;

  // usar o sellerId e buyerId pra mostra o Icon.add ou Icon.remove
  // criar func q pega o simbolo do token

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: .circular(20), 
            side: BorderSide(
              color: Colors.grey.shade300, 
              width: 1
              )
            ),
          child: ListTile(
            dense: true,
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: .circular(20)),
            leading: isBuy 
            ? Icon(Icons.add, color: Colors.green)
            : Icon(Icons.remove, color: Colors.red),
            title: Text(
              token, 
              style: TextStyle(
                fontSize: 18,
                fontWeight: .bold
              )
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantidade: $qtd'),
                Text('Preço por Token: ${moneyFormatter.format(price)}'),
                Text('Executado em: $date'),
              ],
            ),
            subtitleTextStyle: TextStyle(
              color: Colors.black87
            ),
            trailing: Text(
              moneyFormatter.format(price * qtd), 
              style: TextStyle(
                color: Colors.black,
                fontWeight: .bold,
                fontSize: 18
              ),
            ),
          ),
        );
      }
    );
  }
}