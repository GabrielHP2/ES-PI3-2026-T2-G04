// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528
import 'package:flutter/material.dart';
import 'package:frontend/models/order_model.dart';
import 'package:frontend/services/numberformatter_service.dart';

class TokenNegotiation extends StatelessWidget {
  final double currentPrice;
  final OrderType type;

  TokenNegotiation({super.key, required this.currentPrice, required this.type});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: Dialog(
        backgroundColor: Colors.grey[100],
        insetPadding: const EdgeInsets.symmetric(vertical: 100, horizontal: 8),
        shadowColor: Colors.black,
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
                SizedBox(width: 30),
                Text(
                  type == OrderType.buy
                      ? 'CRIAR ORDEM DE COMPRA'
                      : 'CRIAR ORDEM DE VENDA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            SizedBox(height: 13),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  type == OrderType.buy
                      ? 'Preço de compra atual: '
                      : 'Preço de venda atual: ',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight(450)),
                ),
                Text(
                  moneyFormatter.format(currentPrice),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              child: Text(
                type == OrderType.buy
                    ? 'Quantos tokens deseja comprar:'
                    : 'Quantos tokens deseja vender:',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight(450)),
              ),
            ),
            Container(
              padding: EdgeInsets.all(6),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'min: 1',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(200)),
                  ),
                ),
              ),
            ),
            //SizedBox(height: 2),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(10),
              child: Text(
                type == OrderType.buy
                    ? 'Por quanto deseja comprar:'
                    : 'Por quanto deseja vender:',
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight(450)),
              ),
            ),
            Container(
              padding: EdgeInsets.all(6),
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: type == OrderType.buy
                      ? 'R\$ 1,00 (valor de compra imediata)'
                      : 'R\$ 1,00 (valor de venda imediata)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(200)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: null, // TODO: colocar a func de compra/venda
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  type == OrderType.buy ? Colors.green[800] : Colors.red[900],
                ),
              ),
              child: Text(
                type == OrderType.buy
                    ? 'Criar ordem de compra'
                    : 'Criar ordem de venda',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
