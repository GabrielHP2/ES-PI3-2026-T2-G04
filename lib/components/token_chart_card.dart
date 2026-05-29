import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/token.dart';
import 'package:frontend/utils/numberformatter_service.dart';
import 'package:frontend/services/token_services.dart';
import 'package:frontend/services/portfolio_refresh_service.dart';
import 'package:frontend/utils/variation_service.dart';

typedef PriceSpot = ({double x, double y});

class TokenChartCard extends StatefulWidget {
  final String startupId;

  const TokenChartCard({super.key, required this.startupId});

  @override
  State<TokenChartCard> createState() => _TokenChartCardState();
}

class _TokenChartCardState extends State<TokenChartCard> {
  static const List<String> _periodos = ['1D', '1W', '1M', '1Y', '5Y', 'ALL'];

  late Future<Token?> _tokenFuture;
  String _periodoSelecionado = '1M';

  void _refresh() {
    setState(() {
      _tokenFuture = buscarTokenPorStartupId(widget.startupId);
    });
  }

  @override
  void initState() {
    super.initState();
    portfolioRefreshNotifier.addListener(_refresh);
    _tokenFuture = buscarTokenPorStartupId(widget.startupId);
  }

  @override
  void dispose() {
    portfolioRefreshNotifier.removeListener(_refresh);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TokenChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startupId != widget.startupId) {
      _tokenFuture = buscarTokenPorStartupId(widget.startupId);
      _periodoSelecionado = '1M';
    }
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
      final precoAtual = token.precoAtual.toDouble();
      final agora = now.millisecondsSinceEpoch.toDouble();
      final periodoInicio = inicio?.millisecondsSinceEpoch.toDouble() ?? agora;
      return [(x: periodoInicio, y: precoAtual), (x: agora, y: precoAtual)];
    }

    if (pontos.length == 1) {
      final preco = pontos.first.price.toDouble();
      final agora = now.millisecondsSinceEpoch.toDouble();
      final periodoInicio = inicio?.millisecondsSinceEpoch.toDouble() ?? agora;
      return [(x: periodoInicio, y: preco), (x: agora, y: preco)];
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
    if (periodo == _periodoSelecionado) return;
    setState(() => _periodoSelecionado = periodo);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Token?>(
      future: _tokenFuture,
      builder: (context, snapshot) {
        final token = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (isLoading) {
          return _buildCard(
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (token == null) {
          return _buildCard(
            child: const Center(
              child: Text(
                'Sem dados para o período',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          );
        }

        final pontosGrafico = _filtrarParaPontos(token, _periodoSelecionado);
        final variacaoPeriodo = _variacaoDePontos(pontosGrafico);

        return _buildCard(
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
                        formatMoney(token.precoAtual.toDouble()),
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
                        '${variacaoPeriodo >= 0 ? '+' : ''}${variacaoPeriodo.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: variacaoPeriodo >= 0
                              ? Colors.green
                              : Colors.red,
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
                child: pontosGrafico.isEmpty
                    ? const Center(
                        child: Text(
                          'Sem dados para o período',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 20,
                                interval:
                                    pontosGrafico.last.x !=
                                        pontosGrafico.first.x
                                    ? (pontosGrafico.last.x -
                                              pontosGrafico.first.x) /
                                          3
                                    : null,
                                getTitlesWidget: (value, meta) {
                                  if (value == meta.min || value == meta.max) {
                                    return const SizedBox.shrink();
                                  }
                                  final date =
                                      DateTime.fromMillisecondsSinceEpoch(
                                        value.toInt(),
                                      );
                                  String label;
                                  switch (_periodoSelecionado) {
                                    case '1D':
                                      label =
                                          '${date.hour.toString().padLeft(2, '0')}h';
                                      break;
                                    case '1W':
                                      const days = [
                                        'Seg',
                                        'Ter',
                                        'Qua',
                                        'Qui',
                                        'Sex',
                                        'Sáb',
                                        'Dom',
                                      ];
                                      label = days[date.weekday - 1];
                                      break;
                                    case '1M':
                                      label =
                                          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
                                      break;
                                    case '1Y':
                                      const months = [
                                        'Jan',
                                        'Fev',
                                        'Mar',
                                        'Abr',
                                        'Mai',
                                        'Jun',
                                        'Jul',
                                        'Ago',
                                        'Set',
                                        'Out',
                                        'Nov',
                                        'Dez',
                                      ];
                                      label = months[date.month - 1];
                                      break;
                                    default:
                                      label = '${date.year}';
                                  }
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 52,
                                getTitlesWidget: (value, meta) {
                                  if (value == meta.min || value == meta.max) {
                                    return const SizedBox.shrink();
                                  }
                                  final label = value >= 1000
                                      ? 'R\$${(value / 1000).toStringAsFixed(1)}k'
                                      : moneyFormatter.format(value);
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: pontosGrafico.first.x,
                          maxX: pontosGrafico.last.x,
                          minY:
                              pontosGrafico
                                  .map((p) => p.y)
                                  .reduce((a, b) => a < b ? a : b) *
                              0.995,
                          maxY:
                              pontosGrafico
                                  .map((p) => p.y)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.005,
                          lineBarsData: [
                            LineChartBarData(
                              spots:
                                  (pontosGrafico.toList()
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
                                  final data =
                                      DateTime.fromMillisecondsSinceEpoch(
                                        spot.x.toInt(),
                                      );
                                  final dataFormatada =
                                      '${data.day.toString().padLeft(2, '0')}/'
                                      '${data.month.toString().padLeft(2, '0')}/'
                                      '${data.year}';
                                  return LineTooltipItem(
                                    '${formatMoney(spot.y)}\n',
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
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade400,
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
      },
    );
  }

  Widget _buildCard({required Widget child}) {
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
      child: child,
    );
  }
}
