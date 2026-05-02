import 'package:flutter/material.dart';
import 'package:frontend/components/startup_card.dart';
import 'package:frontend/models/startup.dart';
import 'package:frontend/components/filter_button.dart';
import 'package:frontend/pages/detalhada_page.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final List<Startup> _startups = [];

  StartupStage? _selectedFilter;

  void _toggleFilter(StartupStage filter) {
    setState(() {
      _selectedFilter = _selectedFilter == filter ? null : filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    //  Lógica dos filtros
    final startupsFiltradas = _selectedFilter == null
        ? _startups
        : _startups.where((s) => s.estagio == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo de Startups'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros',
              textAlign: TextAlign.left,
            ), // Ajustado .left para TextAlign.left
            const SizedBox(height: 6),
            Container(
              height: 48,
              margin: EdgeInsets.only(bottom: 10),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                scrollDirection: Axis.horizontal,
                children: [
                  FilterButton(
                    data: 'Nova',
                    isPressed: _selectedFilter == StartupStage.nova,
                    onPressed: () => _toggleFilter(StartupStage.nova),
                    icon: Icons.lightbulb,
                    iconBackgroundColor: Color(0xff7AE058),
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    data: 'Em operação',
                    isPressed: _selectedFilter == StartupStage.operacao,
                    onPressed: () => _toggleFilter(StartupStage.operacao),
                    icon: Icons.science,
                    iconBackgroundColor: Colors.deepOrangeAccent,
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    data: 'Em expansão',
                    isPressed: _selectedFilter == StartupStage.expansao,
                    onPressed: () => _toggleFilter(StartupStage.expansao),
                    icon: Icons.public,
                    iconBackgroundColor: Colors.indigo,
                  ),
                ],
              ),
            ),
            Expanded(
              // Construcao de tela
              child: startupsFiltradas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma Startup Disponível',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(right: 16),
                      itemCount: startupsFiltradas.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final Startup startup = startupsFiltradas[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  PaginaDetalhada(startup: startup),
                            ),
                          ),
                          child: StartupCard(startup: startup),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
