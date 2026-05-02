import 'package:flutter/material.dart';
import 'package:frontend/components/startup_info_container.dart';
import 'package:frontend/components/startup_tag.dart';
import 'package:frontend/controllers/startup_controller.dart';
import 'package:frontend/models/startup.dart';
import 'package:frontend/services/numberformatter_service.dart';

class PaginaDetalhada extends StatefulWidget {
  final Startup startup;
  const PaginaDetalhada({super.key, required this.startup});

  @override
  State<PaginaDetalhada> createState() => _PaginaDetalhadaState();
}

class _PaginaDetalhadaState extends State<PaginaDetalhada> {
  @override
  Widget build(BuildContext context) {
    final startup = widget.startup;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("DETALHES", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(startup),
            const SizedBox(height: 16),
            _description(startup),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: startup.tags.map((t) => StartupTag(label: t)).toList(),
            ),
            const SizedBox(height: 20),
            _stats(startup),
            const SizedBox(height: 20),
            _sectionCard(
              title: "Sumário executivo",
              child: Text(
                startup.shortDescription,
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            /*
            _sectionCard(
              title: "Estrutura societária",
              child: Wrap(children: [startup.],),
            ),
            */
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
          startup.tokenSymbol,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        CircleAvatar(
          backgroundColor: getStartupStateColor(startup),
          child: Icon(getStartupStateIcon(startup), color: Colors.white),
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
          infoText: 'R\$ ${formatter.format(startup.metrics.currentRaised)}',
          subText: 'CAPTADO',
        ),
        StartupInfoContainer(
          infoText: formatter.format(startup.metrics.tokensEmitidos),
          subText: 'TOKENS',
        ),
        StartupInfoContainer(
          infoText: formatter.format(startup.metrics.investorsCount),
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

  Widget _ownerTile(String name, String role, String percent) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(role, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const Spacer(),
          Text(
            percent,
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StatCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
