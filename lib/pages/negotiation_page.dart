import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/balance_header.dart';
import 'package:frontend/components/order_book.dart';
import 'package:frontend/components/place_order.dart';
import 'package:frontend/components/user_order_card.dart';
import 'package:frontend/services/token_services.dart';
import 'package:frontend/models/order_model.dart';
import 'package:frontend/models/token.dart';
import 'package:frontend/services/wallet_services.dart';

class NegociacaoPage extends StatefulWidget {
  final Token initialToken;

  const NegociacaoPage({super.key, required this.initialToken});

  @override
  State<NegociacaoPage> createState() => _NegociacaoPageState();
}

class _NegociacaoPageState extends State<NegociacaoPage> {
  final List<String> _periodos = ['1D', '1W', '1M', '1Y', '5Y', 'ALL'];

  String _periodoSelecionado = '1M';
  Token? _token;
  bool _isTokenLoading = true;
  List<Decimal> _historicoFiltrado = [];
  double _saldoUsuario = 0;
  List<OrderModel> _userOrders = [];
  List<OrderModel> _filteredUserOrders = [];
  bool _ordersLoaded = false;

  void _filterOpenOrders() {
    _filteredUserOrders = _userOrders
        .where(
          (o) =>
              o.status == OrderStatus.open || o.status == OrderStatus.partially,
        )
        .toList();
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
    _token = widget.initialToken;
    _historicoFiltrado = _filtrarHistorico(
      widget.initialToken,
      _periodoSelecionado,
    );
    _isTokenLoading = false;
    _fetchData();
  }

  Future<void> _fetchData() async {
    final token = await buscarTokenPorStartupId(widget.initialToken.startupId);
    final wallet = await callWalletBalance();
    final startupId = token?.startupId ?? widget.initialToken.startupId;
    final userOrders = await listOrders();
    if (!mounted) return;

    setState(() {
      if (token != null) {
        _token = token;
        _historicoFiltrado = _filtrarHistorico(token, _periodoSelecionado);
      }
      _saldoUsuario = wallet?.availableBalance ?? 0;
      _userOrders = userOrders.where((o) => o.startupId == startupId).toList();
      _filterOpenOrders();
      _ordersLoaded = true;
    });
  }

  List<Decimal> _filtrarHistorico(Token token, String periodo) {
    final now = DateTime.now();
    DateTime? inicio;

    switch (periodo) {
      case '1D':
        inicio = now.subtract(const Duration(days: 1));
        break;
      case '1W':
        inicio = now.subtract(const Duration(days: 7));
        break;
      case '1M':
        inicio = DateTime(now.year, now.month - 1, now.day);
        break;
      case '1Y':
        inicio = DateTime(now.year - 1, now.month, now.day);
        break;
      case '5Y':
        inicio = DateTime(now.year - 5, now.month, now.day);
        break;
      case 'ALL':
        inicio = null;
        break;
    }

    final pontos = token.priceHistory.where((p) {
      if (inicio == null) return true;
      final d = p.executedAt.toDate();
      return d.isAfter(inicio) || d.isAtSameMomentAs(inicio);
    });

    final precos = pontos.map((p) => p.price).toList();
    if (precos.isEmpty) return token.historicoPrecos;
    if (precos.length == 1) return [precos.first, precos.first];
    return precos;
  }

  void _selecionarPeriodo(String periodo) {
    if (_token == null) return;
    setState(() {
      _periodoSelecionado = periodo;
      _historicoFiltrado = _filtrarHistorico(_token!, periodo);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isTokenLoading || _token == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Negociação')),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BalanceHeader(),
              _buildTokenInfoCard(),
              const SizedBox(height: 16),
              _buildChartCard(),
              const SizedBox(height: 16),
              _buildActionButtons(context),
              const SizedBox(height: 48),
              const Text(
                'Livro de ordens:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Divider(),
              const SizedBox(height: 16),
              OrderBook(type: OrderType.sell, startupId: _token!.startupId),
              const SizedBox(height: 16),
              OrderBook(type: OrderType.buy, startupId: _token!.startupId),
              const SizedBox(height: 16),
              const Text(
                'Suas Ordens Colocadas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Divider(),
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
          ),
        ),
      ),
    );
  }

  Widget _buildTokenInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$ ${_token!.tokenSymbol}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 8),
          Text(
            _token!.nome,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COTAÇÃO ATUAL',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'R\$ ${_token!.precoAtual.toDouble().toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'VALORIZAÇÃO RELATIVA',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_token!.variacao >= 0 ? '+' : ''}${_token!.variacao.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade100),
                bottom: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _historicoFiltrado
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(e.key.toDouble(), e.value.toDouble()),
                        )
                        .toList(),
                    isCurved: true,
                    color: Colors.indigo,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.withValues(alpha: 0.3),
                          Colors.indigo.withValues(alpha: 0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipColor: (_) => Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          'R\$ ${spot.y.toStringAsFixed(2)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _periodos.map((periodo) {
              final isSelected = periodo == _periodoSelecionado;
              return GestureDetector(
                onTap: () => _selecionarPeriodo(periodo),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF5C6BC0)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    periodo,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _abrirPopUp(BuildContext context, OrderType tipo) {
    showDialog(
      context: context,
      builder: (_) => PlaceOrderPopUp(
        token: _token!,
        currentPrice: _token!.precoAtual,
        type: tipo,
        userAvailableBalance: _saldoUsuario,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _abrirPopUp(context, OrderType.buy),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Comprar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _abrirPopUp(context, OrderType.sell),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Vender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
