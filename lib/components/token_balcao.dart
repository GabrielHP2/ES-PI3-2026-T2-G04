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
  // dados
  final List<double> _dadosDiarios = [49.5, 49.8, 50.1, 49.9, 50.0]; // hardcode 

  @override
  Widget build(BuildContext context) {
    final corVariacao = widget.variacao >= 0 ? const Color(0xff7AE058) : Colors.red;
    
    // Pega a lista de preços (apenas diário)
    final dadosDoGrafico = _dadosDiarios;

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