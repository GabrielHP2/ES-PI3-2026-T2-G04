// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/order_model.dart';
import 'package:frontend/pages/order_confirmation.dart';
import 'package:frontend/services/numberformatter_service.dart';

class PlaceOrderPopUp extends StatelessWidget {
  final double currentPrice;
  final OrderType type;

  PlaceOrderPopUp({super.key, required this.currentPrice, required this.type});

  final controllerPrice = MoneyMaskedTextController(
    //Para fazer o input da quantidade de dinheiro estilo pix de bancos
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  final controllerQuantity = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: Dialog(
        backgroundColor: Colors.grey[100],
        insetPadding: const EdgeInsets.symmetric(vertical: 100, horizontal: 16),
        shadowColor: Colors.black,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  SizedBox(width: 8),
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
                  controller: controllerQuantity,
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
                      ? 'Por quanto deseja comprar cada token:'
                      : 'Por quanto deseja vender cada token:',
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight(450)),
                ),
              ),
              Container(
                padding: EdgeInsets.all(6),
                child: TextField(
                  controller: controllerPrice,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: type == OrderType.buy ? 'R\$' : 'R\$',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(200)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  final order = ConfirmOrderModel(
                    price: controllerPrice.numberValue,
                    quantity: int.parse(controllerQuantity.text),
                    startupName: "FinNova",
                    tokenSymbol: "FNOVA",
                    type: type,
                    userName: "João Pedro",
                    userCpf: "400.119.718-94",
                    userBalance: 600.60,
                    userTokenBalance: 6,
                    userAvgPrice: 6,
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => OrderConfirmationPage(order: order),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    type == OrderType.buy ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  type == OrderType.buy
                      ? ' Criar ordem de compra '
                      : ' Criar ordem de venda ',
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
      ),
    );
  }
}
