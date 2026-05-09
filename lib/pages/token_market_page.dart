// Gabriel Hespanholeto Maziero 25004669

import 'package:flutter/material.dart';
import 'package:frontend/pages/wallet_page.dart';
import '../components/token_card.dart';
import '../controllers/balcao_controller.dart';

class TokenMarketPage extends StatefulWidget {
  const TokenMarketPage({super.key});

  @override
  State<TokenMarketPage> createState() => _TokenMarketPageState();
}

class _TokenMarketPageState extends State<TokenMarketPage> {
  double saldoUsuario = 1000;
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
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do saldo
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saldo disponível:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'R\$${saldoUsuario.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WalletPage(),
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.indigo,
                            ),
                          ),
                          icon: const Icon(
                            Icons.credit_card,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.black12, height: 20),
              ],
            ),
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
                        child: CircularProgressIndicator(color: Colors.indigo),
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
                            startupId: token?['startupId'],
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
