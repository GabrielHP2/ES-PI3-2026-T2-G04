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
  final Startup startupExemplo = Startup(
    name: 'FinNova',
    icon: Icons.savings,
    tags: ['Fintech', 'AI'],
    shortDescription:
        'Plataforma de gestão financeira pessoal com IA para análise de gastos e metas de investimento.',
    contributedCapital: 15000.00,
    issuedTokens: 1000,
    startupState: StartupState.nova,
  );
  final Startup startupExemplo1 = Startup(
    name: 'Vizio AI',
    icon: Icons.savings,
    tags: ['Fintech', 'AI'],
    shortDescription:
        'Plataforma de gestão financeira pessoal com IA para análise de gastos e metas de investimento.',
    contributedCapital: 15000.00,
    issuedTokens: 1000,
    startupState: StartupState.development,
  );

  final List<Startup> _startups = [];

  StartupState? _selectedFilter;

  void _toggleFilter(StartupState filter) {
    setState(() {
      _selectedFilter = _selectedFilter == filter ? null : filter;
    });
  }

  @override
  void initState() {
    super.initState();
    //TODO: Puxa as startups do firestore e coloca na lista através de um for
    _startups.add(startupExemplo);
    _startups.add(startupExemplo1);
    _startups.add(startupExemplo1);
    _startups.add(startupExemplo1);
    _startups.add(startupExemplo1);
    _startups.add(startupExemplo1);
    _startups.add(startupExemplo);
    _startups.add(startupExemplo);
    _startups.add(startupExemplo);
    _startups.add(startupExemplo);
  }

  @override
  Widget build(BuildContext context) {
    //  Lógica dos filtros
    final startupsFiltradas = _selectedFilter == null
        ? _startups
        : _startups.where((s) => s.startupState == _selectedFilter).toList();

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
                    isPressed: _selectedFilter == StartupState.nova,
                    onPressed: () => _toggleFilter(StartupState.nova),
                    icon: Icons.lightbulb,
                    iconBackgroundColor: Color(0xff7AE058),
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    data: 'Desenvolvimento',
                    isPressed: _selectedFilter == StartupState.development,
                    onPressed: () => _toggleFilter(StartupState.development),
                    icon: Icons.science,
                    iconBackgroundColor: Colors.deepOrangeAccent,
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    data: 'Expansão',
                    isPressed: _selectedFilter == StartupState.expansion,
                    onPressed: () => _toggleFilter(StartupState.expansion),
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
