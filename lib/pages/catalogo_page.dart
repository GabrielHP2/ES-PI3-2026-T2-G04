// João Pedro Panza Mainieri - 25006642;
import 'package:flutter/material.dart';
import 'package:frontend/components/startup_card.dart';
import 'package:frontend/models/startup.dart';
import 'package:frontend/components/filter_button.dart';
import 'package:frontend/pages/detalhada_page.dart';
import 'package:frontend/services/startup_services.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  List<SimplifiedStartup>? _startups;
  bool _isLoading = true;
  StartupStage? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _fetchStartups();
  }

  Future<void> _fetchStartups() async {
    final result = await callStartupsCatalog();
    if (!mounted) return;
    setState(() {
      _startups = result;
      _isLoading = false;
    });
  }

  void _toggleFilter(StartupStage filter) {
    setState(() {
      _selectedFilter = _selectedFilter == filter ? null : filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    //  Lógica dos filtros
    final startupsFiltradas = _selectedFilter == null
        ? _startups ?? []
        : (_startups ?? []).where((s) => s.stage == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo de Startups'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                          iconBackgroundColor: Colors.green,
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
                              final SimplifiedStartup startup =
                                  startupsFiltradas[index];
                              return GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (context) =>
                                        PaginaDetalhada(startupId: startup.id),
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
