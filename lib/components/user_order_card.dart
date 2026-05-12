import 'package:flutter/material.dart';
import 'package:frontend/models/order_model.dart';
import 'package:frontend/services/numberformatter_service.dart';

class UserOrder extends StatefulWidget {
  final OrderModel order;
  const UserOrder({super.key, required this.order});
  @override
  State<UserOrder> createState() => _UserOrderState();
}

class _UserOrderState extends State<UserOrder> {
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Data não disponível';
    try {
      final dateTime = timestamp.toDate();
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Data inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    OrderModel order = widget.order;
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 2),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: order.type == OrderType.buy
                  ? Icon(Icons.add, color: Colors.green, fontWeight: .w900)
                  : Icon(Icons.remove, color: Colors.red, fontWeight: .w900),
            ),
          ),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$FNOVA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text('Quantidade: ${order.quantity}'),
                Text('Preenchido: ${order.quantityFilled}'),
                Text('Preço por token: ${order.price}'),
                Text('Criado em: ${_formatTimestamp(order.createdAt)}'),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              moneyFormatter.format(order.price * order.quantity),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
