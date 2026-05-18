import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/balance_header.dart';
import 'package:frontend/components/order_book.dart';
import 'package:frontend/components/place_order.dart';
import 'package:frontend/components/user_order_card.dart';
import 'package:frontend/services/numberformatter_service.dart';
import 'package:frontend/models/order_model.dart';
import 'package:frontend/models/token.dart';
import 'package:frontend/services/wallet_services.dart';
import 'package:frontend/services/variation_service.dart';

typedef PriceSpot = ({double x, double y});

class NegociacaoPage extends StatefulWidget {
  final Token initialToken;

  const NegociacaoPage({super.key, required this.initialToken});

  @override
  State<NegociacaoPage> createState() => _NegociacaoPageState();
}

class _NegociacaoPageState extends State<NegociacaoPage> {
  String _periodoSelecionado = '1M';
  Token? _token;
  bool _isTokenLoading = true;
  bool _isChartLoading = true;

  List<PriceSpot> _pontosGrafico = [];
  double _saldoUsuario = 0;
  double _variacaoPeriodo = 0;

  final List<String> _periodos = ['1D', '1W', '1M', '1Y', '5Y', 'ALL'];

  @override
  void initState() {
    super.initState();
    _token = widget.initialToken;
    _isTokenLoading = false;
    _pontosGrafico = _filtrarParaPontos(
      widget.initialToken,
      _periodoSelecionado,
    );
    _variacaoPeriodo = _variacaoDePontos(_pontosGrafico);
    _fetchData();
  }

  Future<void> _fetchData() async {
    final wallet = await callWalletBalance();
    if (!mounted) return;
    setState(() {
      _saldoUsuario = wallet?.availableBalance ?? 0;
    });
    _fetchChart();
  }

  Future<void> _fetchChart() async {
    if (_token == null) return;
    setState(() => _isChartLoading = true);

    final pontos = _filtrarParaPontos(_token!, _periodoSelecionado);
    final variacao = _variacaoDePontos(pontos);

    if (!mounted) return;
    setState(() {
      _pontosGrafico = pontos;
      _variacaoPeriodo = variacao;
      _isChartLoading = false;
    });
  }

  List<PriceSpot> _filtrarParaPontos(Token token, String periodo) {
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
    }).toList();

    if (pontos.isEmpty) {
      if (token.priceHistory.isEmpty) return [];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _periodoSelecionado != 'ALL') {
          setState(() => _periodoSelecionado = 'ALL');
        }
      });
      return token.priceHistory
          .map(
            (p) => (
              x: p.executedAt.toDate().millisecondsSinceEpoch.toDouble(),
              y: p.price.toDouble(),
            ),
          )
          .toList();
    }

    if (pontos.length == 1) {
      final unico = (
        x: pontos.first.executedAt.toDate().millisecondsSinceEpoch.toDouble(),
        y: pontos.first.price.toDouble(),
      );
      return [unico, unico];
    }

    return pontos
        .map(
          (p) => (
            x: p.executedAt.toDate().millisecondsSinceEpoch.toDouble(),
            y: p.price.toDouble(),
          ),
        )
        .toList();
  }

  double _variacaoDePontos(List<PriceSpot> pontos) {
    if (pontos.length < 2) return 0.0;
    return calcularVariacaoPercentual(pontos.first.y, pontos.last.y);
  }

  void _selecionarPeriodo(String periodo) {
    if (_token == null || periodo == _periodoSelecionado) return;

    setState(() => _periodoSelecionado = periodo);
    _fetchChart();
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
              UserOrderList(startupId: _token!.startupId),
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
            '\$${_token!.tokenSymbol}',
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
                    moneyFormatter.format(_token!.precoAtual.toDouble()),
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
                    'VARIAÇÃO NO PERÍODO',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_variacaoPeriodo >= 0 ? '+' : ''}${_variacaoPeriodo.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,

                      color: _variacaoPeriodo >= 0 ? Colors.green : Colors.red,
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
            child: _isChartLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _pontosGrafico.isEmpty
                ? const Center(
                    child: Text(
                      'Sem dados para o período',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minX: _pontosGrafico.first.x,
                      maxX: _pontosGrafico.last.x,

                      minY:
                          _pontosGrafico
                              .map((p) => p.y)
                              .reduce((a, b) => a < b ? a : b) *
                          0.995,
                      maxY:
                          _pontosGrafico
                              .map((p) => p.y)
                              .reduce((a, b) => a > b ? a : b) *
                          1.005,
                      lineBarsData: [
                        LineChartBarData(
                          spots:
                              (_pontosGrafico.toList()
                                    ..sort((a, b) => a.x.compareTo(b.x)))
                                  .map((p) => FlSpot(p.x, p.y))
                                  .toList(),

                          isCurved: false,
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
                              final data = DateTime.fromMillisecondsSinceEpoch(
                                spot.x.toInt(),
                              );
                              final dataFormatada =
                                  '${data.day.toString().padLeft(2, '0')}/'
                                  '${data.month.toString().padLeft(2, '0')}/'
                                  '${data.year}';
                              return LineTooltipItem(
                                '${moneyFormatter.format(spot.y)}\n',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: dataFormatada,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
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
                    color: isSelected ? Colors.indigo : Colors.transparent,
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
