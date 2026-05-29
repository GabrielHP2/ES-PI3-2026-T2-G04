// João Pedro Panza Mainieri - 25006642;
import 'package:flutter/material.dart';
import 'package:frontend/models/token.dart';
import 'package:frontend/pages/negotiation_page.dart';

class TokenCard extends StatelessWidget {
  final Token token;

  const TokenCard({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final corVariacao = token.variacao >= 0 ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NegociacaoPage(initialToken: token)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${token.tokenSymbol}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  token.nome,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R\$${token.precoAtual.toDouble().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '(${token.variacao > 0 ? '+' : ''}${token.variacao.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    fontSize: 14,
                    color: corVariacao,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
