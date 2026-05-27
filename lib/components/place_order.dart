import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/order_model.dart';
import 'package:frontend/models/token.dart';
import 'package:frontend/pages/order_confirmation.dart';
import 'package:frontend/services/token_services.dart';
import 'package:frontend/utils/currency_formatter.dart';
import 'package:frontend/utils/numberformatter_service.dart';

class PlaceOrderPopUp extends StatefulWidget {
  final Token token;
  final Decimal currentPrice;
  final OrderType type;
  final double userAvailableBalance;
  final int userTokenBalance;
  final double userAvgPrice;

  const PlaceOrderPopUp({
    super.key,
    required this.token,
    required this.currentPrice,
    required this.type,
    this.userAvailableBalance = 0,
    this.userTokenBalance = 0,
    this.userAvgPrice = 0,
  });

  @override
  State<PlaceOrderPopUp> createState() => _PlaceOrderPopUpState();
}

class _PlaceOrderPopUpState extends State<PlaceOrderPopUp> {
  bool _isCurrentLoading = true;
  double currentPrice = 0;
  int? currentPriceQuantity;
  final controllerPrice = TextEditingController();
  final controllerQuantity = TextEditingController();

  Future<void> _getBestOrder() async {
    setState(() {
      _isCurrentLoading = true;
    });
    final otherType = widget.type == OrderType.buy
        ? OrderType.sell
        : OrderType.buy;
    final orders = await callGetOrdersByStartupByType(
      widget.token.startupId,
      otherType,
    );

    final openOrders = orders
        .where((o) => o.quantity > o.quantityFilled)
        .toList();

    if (openOrders.isEmpty) {
      setState(() {
        currentPrice = 0;
        currentPriceQuantity = null;
        _isCurrentLoading = false;
      });
      return;
    }

    final bestOrder = openOrders.first;

    setState(() {
      currentPrice = bestOrder.price == 0
          ? widget.currentPrice.toDouble()
          : bestOrder.price;
      currentPriceQuantity = bestOrder.quantity - bestOrder.quantityFilled;
      controllerPrice.value = TextEditingValue(text: formatMoney(currentPrice));
      _isCurrentLoading = false;
    });
  }

  @override
  void initState() {
    controllerPrice.value = TextEditingValue(text: formatMoney(currentPrice));
    controllerQuantity.value = TextEditingValue(text: '1');
    _getBestOrder();
    super.initState();
  }

  @override
  void dispose() {
    controllerPrice.dispose();
    controllerQuantity.dispose();
    super.dispose();
  }

  void _continuar() {
    final quantity = int.tryParse(controllerQuantity.text.trim());
    final price = CurrencyFormatter.getNumericValue();

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Quantidade inválida')));
      return;
    }

    if (price <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preço inválido')));
      return;
    }

    final order = ConfirmOrderModel(
      startupId: widget.token.startupId,
      startupName: widget.token.nome,
      tokenSymbol: widget.token.tokenSymbol,
      type: widget.type,
      quantity: quantity,
      price: price,
      userBalance: widget.userAvailableBalance,
      userTokenBalance: widget.userTokenBalance,
      userAvgPrice: widget.userAvgPrice,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => OrderConfirmationPage(order: order)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.type == OrderType.buy;

    return MediaQuery.removeViewInsets(
      removeBottom: true,
      context: context,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Dialog(
          backgroundColor: Colors.grey[100],
          insetPadding: const EdgeInsets.symmetric(
            vertical: 100,
            horizontal: 16,
          ),
          shadowColor: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isBuy ? 'CRIAR ORDEM DE COMPRA' : 'CRIAR ORDEM DE VENDA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),

                if (_isCurrentLoading)
                  const CircularProgressIndicator()
                else if (currentPrice != 0)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isBuy
                            ? 'Comprar imediatamente por: '
                            : 'Vender imediatamente por: ',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatMoney(currentPrice),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (currentPriceQuantity != null &&
                          currentPriceQuantity! > 0)
                        Column(
                          children: [
                            Text(
                              'Quantidade por este preço: ',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$currentPriceQuantity',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    isBuy
                        ? 'Quantos tokens deseja comprar:'
                        : 'Quantos tokens deseja vender:',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: TextField(
                    textAlign: TextAlign.center,
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
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    isBuy
                        ? 'Por quanto deseja comprar cada token:'
                        : 'Por quanto deseja vender cada token:',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyFormatter.brl,
                    ],
                    controller: controllerPrice,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'R\$ 0,00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(200)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _continuar,
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      isBuy ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    isBuy
                        ? ' Criar ordem de compra '
                        : ' Criar ordem de venda ',
                    style: const TextStyle(
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
      ),
    );
  }
}
