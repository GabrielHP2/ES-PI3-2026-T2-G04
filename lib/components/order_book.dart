import 'package:flutter/material.dart';
import 'package:frontend/services/portfolio_refresh_service.dart';
import 'package:frontend/services/token_services.dart';
import 'package:frontend/models/order_model.dart';
import 'package:frontend/utils/numberformatter_service.dart';

class OrderBook extends StatefulWidget {
  final OrderType type;
  final String startupId;
  const OrderBook({super.key, required this.type, required this.startupId});

  @override
  State<OrderBook> createState() => _OrderBookState();
}

class _OrderBookState extends State<OrderBook> {
  List<OrderModel>? _orders;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrdersByType();
    portfolioRefreshNotifier.addListener(_fetchOrdersByType);
  }

  @override
  void dispose() {
    portfolioRefreshNotifier.removeListener(_fetchOrdersByType);
    super.dispose();
  }

  Future<void> _fetchOrdersByType() async {
    setState(() {
      _isLoading = true;
    });
    final result = await callGetOrdersByStartupByType(
      widget.startupId,
      widget.type,
    );
    setState(() {
      _orders = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 2),
        ],
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: .center,
        children: [
          widget.type == OrderType.buy
              ? Text(
                  'Compras',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.green,
                    fontSize: 24,
                  ),
                )
              : Text(
                  'Vendas',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.red,
                    fontSize: 24,
                  ),
                ),
          const SizedBox(height: 16),
          Table(
            children: [
              const TableRow(
                children: [
                  Text(
                    'Preço',
                    textAlign: .center,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Quantidade',
                    textAlign: .center,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              TableRow(children: [SizedBox(height: 8), SizedBox(height: 8)]),
              if (_orders != null)
                ..._orders!
                    .where((o) => o.quantity > o.quantityFilled)
                    .take(8)
                    .map(
                      (o) => TableRow(
                        children: [
                          Text(
                            moneyFormatter.format(o.price),
                            textAlign: .center,
                          ),
                          Text(
                            (o.quantity - o.quantityFilled).toString(),
                            textAlign: .center,
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          if (_isLoading)
            const Text('Carregando...')
          else if (_orders == null ||
              _orders!.where((o) => o.quantity > o.quantityFilled).isEmpty)
            const Text('Nenhuma ordem colocada'),

          if ((_orders?.where((o) => o.quantity > o.quantityFilled).length ??
                  0) >
              8)
            const Column(
              children: [
                Text(
                  '...',
                  style: TextStyle(color: Colors.black, fontWeight: .bold),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
