import 'package:flutter/material.dart';
import 'package:frontend/services/token_services.dart';
import 'package:frontend/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderConfirmationPage extends StatefulWidget {
  final ConfirmOrderModel order;

  const OrderConfirmationPage({super.key, required this.order});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  bool _isSubmitting = false;
  OrderSubmissionResult? _result;

  Future<void> _confirmar() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final result = await placeOrder(widget.order.toCreateOrderDTO());
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final isBuy = order.type == OrderType.buy;
    final primaryColor = isBuy ? Colors.green : Colors.red;

    if (_result?.success == true) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ordem enviada'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Ordem colocada com sucesso',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(_result!.message),
              const SizedBox(height: 8),
              if (_result!.orderId != null) Text('ID: ${_result!.orderId}'),
              if (_result!.status != null)
                Text('Status: ${_result!.status!.label}'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmar Ordem de ${order.typeLabel}'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _row('Startup', order.startupName),
                  _row('Token', order.tokenSymbol),
                  _row('Tipo', order.typeLabel),
                  _row('Quantidade', '${order.quantity}'),
                  _row('Preço', currency.format(order.price)),
                  const Divider(height: 24),
                  _row('Total', currency.format(order.totalValue)),
                  const Divider(height: 24),
                  _row('Saldo atual', currency.format(order.userBalance)),
                  _row('Saldo após', currency.format(order.balanceAfter)),
                  if (isBuy)
                    _row(
                      'Preço médio após',
                      currency.format(order.avgPriceAfter),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_result != null && _result!.success == false)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _result!.message,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _confirmar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Confirmar',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
