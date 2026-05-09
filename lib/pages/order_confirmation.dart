import 'package:flutter/material.dart';
import 'package:frontend/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderConfirmationPage extends StatefulWidget {
  final ConfirmOrderModel order;

  const OrderConfirmationPage({super.key, required this.order});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage>
    with TickerProviderStateMixin {
  bool _confirmed = false;
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');
    final now = DateTime.now();

    final isBuy = order.type == OrderType.buy;
    final primaryColor = isBuy ? Colors.green : Colors.red;

    if (_confirmed) {
      if (!_timerController.isAnimating && _timerController.value == 0.0) {
        _timerController.forward().then((_) {
          if (mounted) Navigator.pop(context, true);
        });
      }
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Ordem Colocada!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sua ordem foi registrada com sucesso',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedBuilder(
                        animation: _timerController,
                        builder: (context, _) {
                          return Stack(
                            children: [
                              // Fundo escuro (cor base)
                              Container(color: primaryColor),
                              // Fundo claro avançando da esquerda
                              FractionallySizedBox(
                                widthFactor: _timerController.value,
                                alignment: Alignment.bottomCenter,
                                child: Container(color: primaryColor.shade800),
                              ),
                              // Texto centralizado
                              const Center(
                                child: Text(
                                  'FECHAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmar Ordem de ${order.typeLabel}'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCard(
                    children: [
                      _buildSectionTitle('Investidor'),
                      _buildInfoRow('Nome', order.userName),
                      _buildInfoRow('CPF', order.userCpf),
                      _buildDashedDivider(),
                      _buildSectionTitle('Detalhes da Ordem'),
                      _buildInfoRow('Startup', order.startupName),
                      _buildInfoRow('Token', order.tokenSymbol),
                      _buildInfoRow('Tipo', order.typeLabel),
                      _buildInfoRow('Quantidade', '${order.quantity} tokens'),
                      _buildInfoRow(
                        'Preço por token',
                        currencyFormat.format(order.price),
                      ),
                      _buildDashedDivider(),
                      _buildSectionTitle('Resumo da Carteira'),

                      // Saldo em R$
                      _buildBalanceRow(
                        label: 'Saldo atual',
                        before: currencyFormat.format(order.userBalance),
                        after: currencyFormat.format(order.balanceAfter),
                        isNegative: order.type == OrderType.buy,
                      ),

                      // Tokens
                      _buildBalanceRow(
                        label: '\$${order.tokenSymbol} atual',
                        before: '${order.userTokenBalance} tokens',
                        after: '${order.tokenBalanceAfter} tokens',
                        isNegative: order.type == OrderType.sell,
                      ),
                      isBuy
                          ? _buildBalanceRow(
                              label: 'Preço médio atual',
                              before: currencyFormat.format(order.userAvgPrice),
                              after: currencyFormat.format(order.avgPriceAfter),
                              isNegative: order.type == OrderType.sell,
                            )
                          : SizedBox(),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'TOTAL',
                        currencyFormat.format(order.totalValue),
                        isBold: true,
                      ),
                      _buildDashedDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data/Hora',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                dateFormat.format(now),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.indigo.shade200),
                            ),
                            child: Text(
                              'Esperando confirmação',
                              style: TextStyle(
                                color: Colors.indigo.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Aviso
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isBuy
                                ? 'Ao confirmar, ${order.totalValue} do seu saldo será bloqueado na sua carteira até a execução ou exclusão da ordem.'
                                : 'Ao confirmar, ${order.quantity} token(s) serão bloqueados na sua carteira até a execução ou exclusão da ordem.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _confirmed = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Confirmar Ordem',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: List.generate(
          40,
          (i) => Expanded(
            child: Container(
              height: 1,
              color: i.isEven ? Colors.grey.shade300 : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.grey.shade700 : Colors.grey.shade500,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: isBold ? 15 : 13,
                color: color ?? Colors.grey.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow({
    required String label,
    required String before,
    required String after,
    bool isNegative = false,
  }) {
    final arrowColor = isNegative ? Colors.red.shade400 : Colors.green.shade500;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          Row(
            children: [
              Text(
                before,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward, size: 12, color: arrowColor),
              ),
              Text(
                after,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: arrowColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
