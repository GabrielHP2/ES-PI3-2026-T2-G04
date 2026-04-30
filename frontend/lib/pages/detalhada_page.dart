import 'package:flutter/material.dart';
import 'package:frontend/controllers/catalogo_controller.dart';
import 'package:frontend/models/startup.dart';

class PaginaDetalhada extends StatefulWidget {
  final Startup startup;
  const PaginaDetalhada({super.key, required this.startup});

  @override
  State<PaginaDetalhada> createState() => _PaginaDetalhadaState();
}

class _PaginaDetalhadaState extends State<PaginaDetalhada> {
  Widget _buildVideoPlaceholder() {
    return GestureDetector(
      onTap: () {
        // player video
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.play_arrow, size: 50, color: Colors.black54),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Startup startup = widget.startup;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(startup.icon, color: Colors.indigo, size: 34),
                const SizedBox(width: 8),
                // Nome e token ocupam o espaço restante
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          startup.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 34,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${startup.tokenName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Ícone do estado encostado à direita
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: getStartupStateColor(startup),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    getStartupStateIcon(startup),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // VIDEO PLACEHOLDER
          _buildVideoPlaceholder(),

          const Divider(),

          const SizedBox(height: 10),

          // CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sobre a startup',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(startup.shortDescription),
                  SizedBox(height: 12),
                  Text(
                    'Equipe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'A equipe é formada por desenvolvedores, designers e especialistas em negócios com experiência no mercado.',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Produto',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'O principal produto é uma plataforma digital que facilita transações e análise financeira em tempo real.',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Mercado',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'A empresa atua em um mercado em crescimento, com foco em inovação e experiência do usuário.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
