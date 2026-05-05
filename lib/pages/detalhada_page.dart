// Lucas Leonel - RA: 25015188

import 'package:flutter/material.dart';
import 'package:frontend/components/questions_section.dart';
import 'package:frontend/components/startup_info_container.dart';
import 'package:frontend/components/startup_tag.dart';
import 'package:frontend/controllers/startup_controller.dart';
import 'package:frontend/models/startup.dart';
import 'package:frontend/services/numberformatter_service.dart';
import 'package:frontend/services/startup_services.dart';
import 'package:video_player/video_player.dart';

class PaginaDetalhada extends StatefulWidget {
  final String startupId;

  const PaginaDetalhada({super.key, required this.startupId});

  @override
  State<PaginaDetalhada> createState() => _PaginaDetalhadaState();
}

class _PaginaDetalhadaState extends State<PaginaDetalhada> {
  Startup? _startup;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStartups();
  }

  Future<void> _fetchStartups() async {
    final result = await callStartupDetail(widget.startupId);
    setState(() {
      _startup = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("DETALHES", style: TextStyle(color: Colors.black)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  _sectionCard(
                    title: "Sumário executivo",
                    child: Text(
                      _startup!.shortDescription,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _sectionCard(
                    title: "Estrutura societária",
                    child: Wrap(
                      children: _startup!.corporateStructure
                          .map((s) => _ownerTile(s))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    title: 'Perguntas e respostas públicas',
                    child: QuestionsSection(),
                  ),
                  const SizedBox(height: 16),
                  _videosShow(_startup!),
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

  Widget _sectionCard({required String title, required Widget child}) {
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
    
    return _sectionCard(
      title: "Vídeo demonstrativo",
      child: GestureDetector(
        onTap: () => _openVideoPlayer(startup.pitchVideoUrl),
        child: Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // fundo escuro (placeholder)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black87,
                ),
              ),

              // botão play
              const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 50,
              ),
            ],
          ),
        ),
      ),
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

  void _openVideoPlayer(String url) {
  final controller = VideoPlayerController.network(url);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black,
    builder: (_) {
      return FutureBuilder(
        future: controller.initialize(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          controller.play();

          return AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(controller),
                VideoProgressIndicator(controller, allowScrubbing: true),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      controller.dispose();
                      Navigator.pop(context);
                    },
                  ),
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
}
