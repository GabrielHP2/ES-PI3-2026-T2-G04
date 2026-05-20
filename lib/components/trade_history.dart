// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import 'package:flutter/material.dart';

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


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            tileColor: Colors.white,
            leading: Icon(
              Icons.add, 
              color: Colors.green,
            ),
            title: Text(
              token, 
              style: TextStyle(
                fontSize: 12,
                fontWeight: .bold
              )
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantidade: $qtd'),
                Text('Preço por Token: R\$ $price'),
                Text('Executado em $date'),
              ],
            ),
            trailing: Text('R\$ ${qtd * price}'),
          ),
        );
      }
    );
  }
}