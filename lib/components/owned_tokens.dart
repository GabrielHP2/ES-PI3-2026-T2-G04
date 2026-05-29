import 'package:flutter/material.dart';
import 'package:frontend/components/card_container.dart';
import 'package:frontend/components/token_chart_card.dart';
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
  List<Holding> _userHoldings = [];

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
    setState(() => _isLoading = true);
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
    setState(() {
      _userHoldings = wallet.holdings;
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
            separatorBuilder: (context, index) => const SizedBox(height: 24),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _userHoldings.length,
            itemBuilder: (context, index) {
              return OwnedTokenCard(holding: _userHoldings[index]);
            },
          );
  }
}

class OwnedTokenCard extends StatefulWidget {
  final Holding holding;
  const OwnedTokenCard({super.key, required this.holding});

  @override
  State<OwnedTokenCard> createState() => _OwnedTokenCardState();
}

class _OwnedTokenCardState extends State<OwnedTokenCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: CardContainer(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${widget.holding.tokenSymbol}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        'Quantidade disponível: ${widget.holding.tokenBalance}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Quantidade à venda: ${widget.holding.blockedTokenBalance}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Preço médio por token: ${formatMoney(widget.holding.avgPrice)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatMoney(
                          widget.holding.tokenBalance * widget.holding.avgPrice,
                        ),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          TokenChartCard(startupId: widget.holding.startupId),
        ],
      ],
    );
  }
}
