import 'package:flutter/material.dart';
import 'package:frontend/controllers/balcao_controller.dart';
import 'package:frontend/models/order_model.dart';

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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(widget.type == OrderType.buy ? 'Compras' : 'Vendas'),
          Table(
            children: [
              const TableRow(children: [Text('Preço'), Text('Quantidade')]),
              if (_isLoading)
                const TableRow(children: [Text('Carregando...'), Text('')])
              else if (_orders == null || _orders!.isEmpty)
                const TableRow(children: [Text('Nenhuma ordem colocada'), Text('')])
              else
                ..._orders!
                    .map(
                      (o) => TableRow(
                        children: [
                          Text(o.price.toStringAsFixed(2)),
                          Text(o.quantity.toString()),
                        ],
                      ),
                    )
                    .toList(),
            ],
          ),
        ],
      ),
    );
  }
}
