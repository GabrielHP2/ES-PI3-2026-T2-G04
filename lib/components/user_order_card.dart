import 'package:flutter/material.dart';
import 'package:frontend/models/order_model.dart';
import 'package:frontend/utils/numberformatter_service.dart';
import 'package:frontend/services/portfolio_refresh_service.dart';
import 'package:frontend/services/token_services.dart';

class UserOrder extends StatefulWidget {
  final OrderModel order;
  final ValueChanged<String>? onOrderCancelled;

  const UserOrder({super.key, required this.order, this.onOrderCancelled});

  @override
  State<UserOrder> createState() => _UserOrderState();
}

class _UserOrderState extends State<UserOrder> {
  bool _isCancelling = false;

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

    return Dismissible(
      key: ValueKey(order.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
      ),
      confirmDismiss: (_) async {
        if (_isCancelling) return false;

        final messenger = ScaffoldMessenger.of(context);
        final shouldCancel =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancelar ordem?'),
                content: const Text(
                  'Esta ação irá cancelar a ordem selecionada.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Voltar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
            ) ??
            false;

        if (!shouldCancel) return false;

        setState(() => _isCancelling = true);
        final result = await callCancelOrder(order.id);
        if (!mounted) return false;
        setState(() => _isCancelling = false);

        messenger.hideCurrentSnackBar();

        if (!result.success) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }

        return true;
      },
      onDismissed: (_) {
        widget.onOrderCancelled?.call(order.id);
        requestPortfolioRefresh();
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Ordem cancelada com sucesso.'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Opacity(
        opacity: _isCancelling ? 0.5 : 1,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '\$${order.tokenSymbol}:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  order.type == OrderType.buy
                      ? Text(
                          ' Ordem de compra',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          ' Ordem de venda',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantidade: ${order.quantity}'),
                        Text('Preenchido: ${order.quantityFilled}'),
                        Text('Preço por token: ${formatMoney(order.price)}'),
                        Text('Criado em: ${_formatTimestamp(order.createdAt)}'),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      formatMoney(order.price * order.quantity),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.swipe_left,
                    size: 14,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'deslize para cancelar',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red.shade300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserOrderList extends StatefulWidget {
  final String? startupId;
  const UserOrderList({super.key, this.startupId});
  @override
  State<UserOrderList> createState() => _UserOrderListState();
}

class _UserOrderListState extends State<UserOrderList> {
  List<OrderModel> _userOrders = [];
  List<OrderModel> _filteredUserOrders = [];
  bool _ordersLoaded = false;

  void _handlePortfolioRefresh() {
    _fetchData();
  }

  void _filterOpenOrders() {
    if (widget.startupId == null) {
      _filteredUserOrders = _userOrders
          .where(
            (o) =>
                o.status == OrderStatus.open ||
                o.status == OrderStatus.partially,
          )
          .toList();
    } else {
      _filteredUserOrders = _userOrders
          .where(
            (o) =>
                (o.status == OrderStatus.open ||
                    o.status == OrderStatus.partially) &&
                (o.startupId == widget.startupId),
          )
          .toList();
    }
  }

  void _removeUserOrder(String orderId) {
    setState(() {
      _userOrders.removeWhere((o) => o.id == orderId);
      _filterOpenOrders();
    });
  }

  @override
  void initState() {
    super.initState();
    portfolioRefreshNotifier.addListener(_handlePortfolioRefresh);
    _fetchData();
  }

  @override
  void dispose() {
    portfolioRefreshNotifier.removeListener(_handlePortfolioRefresh);
    super.dispose();
  }

  Future<void> _fetchData() async {
    final result = await listOrders();
    if (!mounted) return;

    setState(() {
      _userOrders = result;
      _filterOpenOrders();
      _ordersLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_ordersLoaded)
          const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_filteredUserOrders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Nenhuma ordem encontrada.'),
          )
        else
          ..._filteredUserOrders.map(
            (o) => UserOrder(
              key: ValueKey(o.id),
              order: o,
              onOrderCancelled: _removeUserOrder,
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
