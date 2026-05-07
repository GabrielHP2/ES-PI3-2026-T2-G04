// Gabriel Hespanholeto Maziero 25004669

import 'package:flutter/material.dart';
import '../components/token_balcao.dart';
import '../controllers/balcao_controller.dart';

class TokenMarketPage extends StatefulWidget {
  const TokenMarketPage({super.key});

  @override
  State<TokenMarketPage> createState() => _TokenMarketPageState();
}

class _TokenMarketPageState extends State<TokenMarketPage> {
  List<Map<String, dynamic>?> _tokens = [];
  bool _isLoading = true;

  Future<void> _fetchTokens() async {
    setState(() {
      _isLoading = true;
    });

    final result = await buscarTokens();

    setState(() {
      _tokens = result;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState;
    _fetchTokens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Balcão de tokens'),
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
                const Text(
                  'Seu saldo:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    // O saldo ainda está hardcoded, isso mudará quando vocês integrarem a tabela de Usuários
                    const Text(
                      'R\$0,00',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF5759E0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),
            const Text(
              'Tokens de startups',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // API
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchTokens(),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF5759E0),
                        ),
                      )
                    : _tokens.isEmpty
                    ? const Center(
                        child: Text(
                          'Sem Tokens disponíveis.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tokens.length,
                        itemBuilder: (context, index) {
                          final token = _tokens[index];
                          return TokenCard(
                            ticker: token?['token_symbol'],
                            nome: token?['nome'],
                            precoAtual: token?['precoAtual'],
                            variacao: token?['variacao'],
                            historicoPrecos: token?['historico'],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
