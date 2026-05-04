// Gabriel Hespanholeto Maziero 25004669

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TokenCard extends StatefulWidget {
  final String ticker;
  final String nome;
  final double precoAtual;
  final double variacao;

  const TokenCard({
    super.key,
    required this.ticker,
    required this.nome,
    required this.precoAtual,
    required this.variacao,
  });

  @override
  State<TokenCard> createState() => _TokenCardState();
}

class _TokenCardState extends State<TokenCard> {
  // selecao do filtro
  String _filtroSelecionado = 'Diário';

  // dados
  final Map<String, List<double>> _historicoMock = {
    'Diário': [49.5, 49.8, 50.1, 49.9, 50.0],
    'Semanal': [45.0, 47.2, 46.5, 48.0, 50.0],
    'Mensal': [40.0, 42.0, 41.0, 45.0, 48.0, 50.0],
    '6 Meses': [30.0, 35.0, 32.0, 40.0, 45.0, 50.0],
    'YTD': [25.0, 28.0, 35.0, 42.0, 48.0, 50.0],
  };

  // funcao de reconstrução do grafico
  void _mudarFiltro(String novoFiltro) {
    setState(() {
      _filtroSelecionado = novoFiltro;
    });
  }

  @override
  Widget build(BuildContext context) {
    final corVariacao = widget.variacao >= 0 ? const Color(0xff7AE058) : Colors.red;
    
    // Pega a lista de preços baseada no botão clicado
    final dadosDoGrafico = _historicoMock[_filtroSelecionado]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCACACA), width: 1),
      ),
      child: Column(
        children: [
          // info token
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.ticker, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(widget.nome, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('R\$${widget.precoAtual.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    '${widget.variacao > 0 ? '+' : ''}${widget.variacao.toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 14, color: corVariacao, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),

          // ---> grafico <---
          SizedBox(
            height: 60, 
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          'R\$ ${spot.y.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _gerarPontosDoGrafico(dadosDoGrafico),
                    isCurved: true,
                    color: corVariacao,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // filtro do tempo
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _historicoMock.keys.map((String nomeFiltro) {
                final isSelected = _filtroSelecionado == nomeFiltro;
                
                return GestureDetector(
                  onTap: () => _mudarFiltro(nomeFiltro),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF5759E0) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF5759E0) : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        nomeFiltro,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // converte double 
  List<FlSpot> _gerarPontosDoGrafico(List<double> dados) {
    return dados.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }
}