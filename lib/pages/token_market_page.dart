// Gabriel Hespnholeto Maziero 25004669

import 'package:flutter/material.dart';
import '../components/token_balcao.dart'; // 

class TokenMarketPage extends StatelessWidget {
  const TokenMarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        title: const Text('BALCÃO DE TOKENS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do saldo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Seu saldo:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    const Text('R\$0,00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFF5759E0), shape: BoxShape.circle),
                      child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                    )
                  ],
                )
              ],
            ),
            const Divider(height: 30, thickness: 1),
            const Text('Tokens de startups', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // lista tokens
            Expanded(
              child: ListView(
                children: const [
                  TokenCard(
                    ticker: '\$FNOVA',
                    nome: 'FinNova',
                    precoAtual: 50.00,
                    variacao: 10.0,
                  ),
                  TokenCard(
                    ticker: '\$AGROX',
                    nome: 'AgroTech',
                    precoAtual: 22.50,
                    variacao: -3.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}