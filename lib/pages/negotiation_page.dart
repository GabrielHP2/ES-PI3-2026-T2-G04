import 'package:flutter/material.dart';
import 'package:frontend/components/balance_header.dart';
import 'package:frontend/components/token_chart_card.dart';
import 'package:frontend/components/order_book.dart';
import 'package:frontend/components/place_order.dart';
import 'package:frontend/components/user_order_card.dart';
import 'package:frontend/models/order_model.dart';
import 'package:frontend/models/token.dart';
import 'package:frontend/services/portfolio_refresh_service.dart';
import 'package:frontend/services/wallet_services.dart';

class NegociacaoPage extends StatefulWidget {
  final Token initialToken;

  const NegociacaoPage({super.key, required this.initialToken});

  @override
  State<NegociacaoPage> createState() => _NegociacaoPageState();
}

class _NegociacaoPageState extends State<NegociacaoPage> {
  Token? _token;
  bool _isTokenLoading = true;
  double _saldoUsuario = 0;

  @override
  void initState() {
    super.initState();
    portfolioRefreshNotifier.addListener(_fetchData);
    _token = widget.initialToken;
    _isTokenLoading = false;
    _fetchData();
  }

  @override
  void dispose() {
    portfolioRefreshNotifier.removeListener(_fetchData);
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isTokenLoading = true;
    });
    final wallet = await callWalletBalance();
    if (!mounted) return;
    setState(() {
      _saldoUsuario = wallet?.availableBalance ?? 0;
      _isTokenLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isTokenLoading || _token == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Negociação')),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BalanceHeader(),
              _buildTokenInfoCard(),
              const SizedBox(height: 16),
              TokenChartCard(startupId: _token!.startupId),
              const SizedBox(height: 16),
              _buildActionButtons(context),
              const SizedBox(height: 48),
              const Text(
                'Livro de ordens:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Divider(),
              const SizedBox(height: 16),
              OrderBook(type: OrderType.sell, startupId: _token!.startupId),
              const SizedBox(height: 16),
              OrderBook(type: OrderType.buy, startupId: _token!.startupId),
              const SizedBox(height: 16),
              const Text(
                'Suas Ordens Colocadas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Divider(),
              UserOrderList(startupId: _token!.startupId),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$${_token!.tokenSymbol}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 8),
          Text(
            _token!.nome,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _abrirPopUp(BuildContext context, OrderType tipo) {
    showDialog(
      context: context,
      builder: (_) => PlaceOrderPopUp(
        token: _token!,
        currentPrice: _token!.precoAtual,
        type: tipo,
        userAvailableBalance: _saldoUsuario,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _abrirPopUp(context, OrderType.buy),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Comprar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _abrirPopUp(context, OrderType.sell),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Vender',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
