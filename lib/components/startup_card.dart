import 'package:flutter/material.dart';
import 'package:frontend/components/startup_info_container.dart';
import 'package:frontend/models/startup.dart';
import 'package:frontend/controllers/startup_controller.dart';
import 'package:frontend/services/numberformatter_service.dart';
import 'package:frontend/components/startup_tag.dart';

class StartupCard extends StatelessWidget {
  final SimplifiedStartup startup;

  const StartupCard({required this.startup, super.key});

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.96;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: SizedBox(
        width: cardWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Conteúdo principal
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com ícone e título
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        startup.icon,
                        color: const Color(0xFF4A51E0),
                        size: 34,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        startup.name,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Tags (chips estilo outline)
                  Wrap(
                    spacing: 6,
                    runSpacing: 8,
                    children: startup.tags
                        .map((t) => StartupTag(label: t))
                        .toList(),
                  ),

                  const SizedBox(height: 12),

                  // Descrição
                  Text(
                    startup.shortDescription.length > 100
                        ? '${startup.shortDescription.substring(0, 100)}...'
                        : startup.shortDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: .center,
                    spacing: 8,
                    children: [
                      StartupInfoContainer(
                        infoText:
                            'R\$ ${formatter.format(startup.currentRaised)}',
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
                  ),
                ],
              ),
            ),

            // Ribbon posicionado no canto superior direito
            Positioned(
              top: 0,
              right: 32,
              child: _Ribbon(
                icon: getStartupStateIcon(startup.stage),
                color: getStartupStateColor(startup.stage),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Ribbon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _Ribbon({this.icon = Icons.business_center, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: 36,
                height: 36,
                child: Icon(icon, color: Colors.white, size: 26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
