import 'package:flutter/material.dart';
import 'package:frontend/components/balance_header.dart';
import 'package:frontend/components/token_card.dart';
import 'package:frontend/services/token_services.dart';
import 'package:frontend/models/token.dart';

class TokenMarketPage extends StatefulWidget {
  const TokenMarketPage({super.key});

  @override
  State<TokenMarketPage> createState() => _TokenMarketPageState();
}

class _TokenMarketPageState extends State<TokenMarketPage> {
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

  @override
  void initState() {
    super.initState();
    _fetchTokens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balcão de tokens'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceHeader(),
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
