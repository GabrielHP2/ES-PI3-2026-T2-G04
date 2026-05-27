import 'package:flutter/material.dart';
import 'package:frontend/components/card_container.dart';
import 'package:frontend/models/wallet.dart';
import 'package:frontend/utils/numberformatter_service.dart';
import 'package:frontend/services/portfolio_refresh_service.dart';
import 'package:frontend/services/wallet_services.dart';

class OwnedTokensList extends StatefulWidget {
  const OwnedTokensList({super.key});
  @override
  State<OwnedTokensList> createState() => _OwnedTokensListState();
}

class _OwnedTokensListState extends State<OwnedTokensList> {
  bool _isLoading = true;
  List<Holding?> _userHoldings = []; // Mudar tipo para List<Holdings>

  void _handlePortfolioRefresh() {
    _fetchData();
  }

  @override
  void initState() {
    super.initState();
    portfolioRefreshNotifier.addListener(_handlePortfolioRefresh);
    _fetchData();
  }

  @override
  void dispose() {
    portfolioRefreshNotifier.removeListener(_handlePortfolioRefresh);
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    final wallet = await callWalletHoldings();
    if (!mounted) return;
    if (wallet == null) {
      setState(() {
        _userHoldings = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar os tokens da carteira')),
      );
      return;
    }
    final holdings = wallet.holdings;

    setState(() {
      _userHoldings = holdings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _userHoldings.isEmpty
        ? const Center(child: Text('Você ainda não possui nenhum token'))
        : ListView.separated(
            separatorBuilder: (context, index) => SizedBox(height: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _userHoldings.length,
            itemBuilder: (context, index) {
              final holding = _userHoldings[index]!;
              return OwnedTokenCard(holding: holding);
            },
          );
  }
}

class OwnedTokenCard extends StatefulWidget {
  final Holding holding; // Criar model Holding
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
            flex: 2,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  '\$${widget.holding.tokenSymbol}',
                  style: TextStyle(fontWeight: .bold, fontSize: 24),
                ),
                Text(
                  'Quantidade disponível: ${widget.holding.tokenBalance}',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  'Quantidade á venda: ${widget.holding.blockedTokenBalance}',

                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  'Preço médio por token: ${formatMoney(widget.holding.avgPrice)}',

                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(
                  formatMoney(
                    widget.holding.tokenBalance * widget.holding.avgPrice,
                  ),
                  style: TextStyle(fontSize: 20, fontWeight: .bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
