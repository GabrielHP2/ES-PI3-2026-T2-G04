// Lucas Leonel - RA: 25015188

import 'package:flutter/material.dart';
import 'package:frontend/components/balance_header.dart';
import 'package:frontend/components/owned_tokens.dart';
import 'package:frontend/components/questions_section.dart';
import 'package:frontend/components/startup_info_container.dart';
import 'package:frontend/components/startup_tag.dart';
import 'package:frontend/components/token_chart_card.dart';
import 'package:frontend/controllers/startup_controller.dart';
import 'package:frontend/models/startup.dart';
import 'package:frontend/models/wallet.dart';
import 'package:frontend/services/is_investor_service.dart';
import 'package:frontend/utils/numberformatter_service.dart';
import 'package:frontend/services/startup_services.dart';
import 'package:frontend/services/wallet_services.dart';
import 'package:video_player/video_player.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend/components/place_order.dart';
import 'package:frontend/models/order_model.dart';
import 'package:frontend/models/token.dart';
import 'package:frontend/pages/negotiation_page.dart';

class PaginaDetalhada extends StatefulWidget {
  final String startupId;

  const PaginaDetalhada({super.key, required this.startupId});

  @override
  State<PaginaDetalhada> createState() => _PaginaDetalhadaState();
}

class _PaginaDetalhadaState extends State<PaginaDetalhada> {
  Startup? _startup;
  bool _isLoading = true;

  ScrollController _scrollController = ScrollController();
  bool _isUserInvestor = false;
  double _userAvailableBalance = 0;
  Holding? _userHolding;

  @override
  void initState() {
    super.initState();
    _fetchStartups();
  }

  Future<void> _fetchStartups() async {
    setState(() {
      _isLoading = true;
    });
    final result = await callStartupDetail(widget.startupId);
    _isUserInvestor = await callIsUserInvestor(widget.startupId);

    if (_isUserInvestor) {
      final wallet = await callWalletBalance();
      _userAvailableBalance = wallet?.availableBalance ?? 0;
      await _fetchHolding();
    }

    setState(() {
      _startup = result;
      _isLoading = false;
    });
  }

  Future<void> _fetchHolding() async {
    final result = await callWalletHoldings();
    if (result == null) return;
    if (result.holdings.isEmpty) {
      return;
    }
    final Holding tokenHolding = result.holdings.firstWhere(
      (h) => h.startupId == widget.startupId,
    );
    setState(() {
      _userHolding = tokenHolding;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isUserInvestor
          ? FloatingActionButton.extended(
              label: Text('Ir para área do investidor'),
              backgroundColor: Colors.amber,
              onPressed: () => _scrollController.animateTo(
                1500.0,
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
              ),
              //icon: Icon(Icons.monetization_on),
            )
          : SizedBox(),
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Detalhes da startup",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _header(_startup!),
                  const SizedBox(height: 16),
                  _description(_startup!),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    runSpacing: 8,
                    children: _startup!.tags
                        .map((t) => StartupTag(label: t))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  _stats(_startup!),
                  const SizedBox(height: 20),
                  sectionCard(
                    title: "Sumário executivo",
                    child: Text(
                      _startup!.shortDescription,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  sectionCard(
                    title: "Estrutura societária",
                    child: Wrap(
                      children: _startup!.corporateStructure
                          .map((s) => _ownerTile(s))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  sectionCard(
                    title: 'Perguntas e respostas públicas',
                    child: QuestionsSection(
                      startupId: widget.startupId,
                      isPublic: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _videosShow(_startup!),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _goToNegotiationPage, // TODO: finalizar a func
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ir para página de negociação',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _isUserInvestor
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Área do investidor',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  /*Icon(
                                    Icons.monetization_on,
                                    color: Colors.amber,
                                  ),*/
                                ],
                              ),
                            ),

                            const Divider(),
                            const SizedBox(height: 16),
                            BalanceHeader(),
                            const SizedBox(height: 16),
                            OwnedTokenCard(holding: _userHolding!),
                            const SizedBox(height: 16),
                            TokenChartCard(startupId: widget.startupId),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () =>
                                      _showPlaceOrderPopup(OrderType.buy),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
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
                                const SizedBox(width: 57),
                                ElevatedButton(
                                  onPressed: () =>
                                      _showPlaceOrderPopup(OrderType.sell),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 21,
                                    ),
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
                              ],
                            ),
                            const SizedBox(height: 16),
                            sectionCard(
                              title: 'Perguntas e respostas privadas',
                              child: QuestionsSection(
                                startupId: widget.startupId,
                                isPublic: false,
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  const SizedBox(height: 64),
                ],
              ),
            ),
    );
  }

  Widget _header(Startup startup) {
    return Row(
      children: [
        Icon(startup.icon, size: 36, color: Colors.indigo),
        const SizedBox(width: 10),
        Text(
          startup.name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          '\$${startup.tokenSymbol}',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        CircleAvatar(
          backgroundColor: getStartupStateColor(_startup!.stage),
          child: Icon(
            getStartupStateIcon(_startup!.stage),
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _description(Startup startup) {
    return Text(startup.shortDescription, style: TextStyle(fontSize: 14));
  }

  Widget _stats(Startup startup) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StartupInfoContainer(
          infoText: 'R\$ ${formatter.format(startup.currentRaised)}',
          subText: 'CAPTADO',
        ),
        StartupInfoContainer(
          infoText: formatter.format(startup.tokensIssued),
          subText: 'TOKENS',
        ),
        StartupInfoContainer(
          infoText: formatter.format(startup.investorsCount),
          subText: 'INVESTIDORES',
        ),
      ],
    );
  }

  Widget sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _ownerTile(CorporateMember member) {
    return GestureDetector(
      onTap: () => _showPartnerPresentation(member),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigo,
              radius: 16,
              child: Text(
                _initials(member.name),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(member.role, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const Spacer(),
            Text(
              '${member.equityPercent}%',
              style: const TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videosShow(Startup startup) {
    if (startup.pitchVideoUrl.isEmpty) return SizedBox();

    return sectionCard(
      title: "Vídeo demonstrativo",
      child: _InlineVideoPlayer(url: startup.pitchVideoUrl),
    );
  }

  void _showPartnerPresentation(CorporateMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.3,
          minChildSize: 0.2,
          maxChildSize: 0.5,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo,
                        radius: 28,
                        child: Text(
                          _initials(member.name),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              member.role,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${member.equityPercent}%',
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Apresentação',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member.bio.isNotEmpty
                        ? member.bio
                        : 'Sem apresentação disponível.',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  void _showPlaceOrderPopup(OrderType orderType) {
    final token = Token(
      startupId: _startup!.id,
      nome: _startup!.name,
      tokenSymbol: _startup!.tokenSymbol,
      precoAtual: Decimal.parse(_startup!.lastPrice.toString()),
      currentRaised: Decimal.parse(_startup!.currentRaised.toString()),
      priceHistory: [],
      variacao: 0.0,
    );

    showDialog(
      context: context,
      builder: (context) => PlaceOrderPopUp(
        token: token,
        currentPrice: Decimal.parse(_startup!.lastPrice.toString()),
        type: orderType,
        userAvailableBalance: _userAvailableBalance,
        userTokenBalance: (_userHolding?.tokenBalance ?? 0).toInt(),
        userAvgPrice: _userHolding?.avgPrice ?? 0,
      ),
    );
  }

  void _goToNegotiationPage() {
    final token = Token(
      startupId: _startup!.id,
      nome: _startup!.name,
      tokenSymbol: _startup!.tokenSymbol,
      precoAtual: Decimal.parse(_startup!.lastPrice.toString()),
      currentRaised: Decimal.parse(_startup!.currentRaised.toString()),
      priceHistory: [],
      variacao: 0.0,
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NegociacaoPage(initialToken: token)),
    );
  }
}

class _InlineVideoPlayer extends StatefulWidget {
  final String url;

  const _InlineVideoPlayer({required this.url});

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  late final VideoPlayerController _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Não foi possível carregar o vídeo.';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: () {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
          setState(() {});
        },
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: _controller.value.isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  padding: const EdgeInsets.only(bottom: 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
