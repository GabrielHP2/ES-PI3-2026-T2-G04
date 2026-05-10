import 'package:flutter/material.dart';
import 'package:frontend/components/token_card.dart';
import 'package:frontend/controllers/balcao_controller.dart';
import 'package:frontend/models/token.dart';
import 'package:frontend/pages/wallet_page.dart';
import 'package:frontend/services/numberformatter_service.dart';
import 'package:frontend/services/wallet_services.dart';

class TokenMarketPage extends StatefulWidget {
  const TokenMarketPage({super.key});

  @override
  State<TokenMarketPage> createState() => _TokenMarketPageState();
}

class _TokenMarketPageState extends State<TokenMarketPage> {
  double _saldoUsuario = 0;
  List<Token> _tokens = <Token>[];
  bool _isLoading = true;

  Future<void> _fetchTokens() async {
    setState(() => _isLoading = true);
    final result = await buscarTokens();
    if (!mounted) return;
    setState(() {
      _tokens = result;
      _isLoading = false;
    });
  }

  Future<void> _fetchData() async {
    _fetchTokens();
    final wallet = await callWalletBalance();

    if (!mounted) return;

    setState(() {
      _saldoUsuario = wallet?.availableBalance ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          moneyFormatter.format(_saldoUsuario),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const WalletPage(),
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchTokens,
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
                        itemBuilder: (_, index) {
                          final token = _tokens[index];
                          return TokenCard(token: token);
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
