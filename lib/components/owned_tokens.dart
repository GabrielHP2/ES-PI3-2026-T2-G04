import 'package:flutter/material.dart';
import 'package:frontend/components/card_container.dart';
import 'package:frontend/models/token.dart';
import 'package:frontend/services/numberformatter_service.dart';
import 'package:frontend/services/wallet_services.dart';

class OwnedTokensList extends StatefulWidget {
  const OwnedTokensList({super.key});
  @override
  State<OwnedTokensList> createState() => _OwnedTokensListState();
}

class _OwnedTokensListState extends State<OwnedTokensList> {
  bool _isLoading = true;
  List<Token?> _userHoldings = []; // Mudar tipo para List<Holdings>

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    final wallet =
        await callWalletBalance(); // Mudar para função que pega as holdings
    if (!mounted) return;

    setState(() {
      // _userHoldings = wallet (pegar holdings)
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _userHoldings.isEmpty
        ? Center(child: Text('Você ainda não possui nenhum token'))
        : ListView.builder(
            itemBuilder: (context, index) {
              final holding = _userHoldings[index]!;
              OwnedTokenCard(holding: holding);
            },
          );
  }
}

class OwnedTokenCard extends StatefulWidget {
  final Token holding; // Criar model Holding
  const OwnedTokenCard({super.key, required this.holding});
  @override
  State<OwnedTokenCard> createState() => _OwnedTokenCardState();
}

class _OwnedTokenCardState extends State<OwnedTokenCard> {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text('\$${widget.holding.tokenSymbol}'),
                Text('Quantidade: ${widget.holding}'),
                Text('Quantidade á venda: ${widget.holding}'),
                Text('Preço médio por token: ${widget.holding}'),
              ],
            ),
          ),
          Expanded(
            child: Text(moneyFormatter.format(widget.holding.precoAtual)),
          ),
        ],
      ),
    );
  }
}
