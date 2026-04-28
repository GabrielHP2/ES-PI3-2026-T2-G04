import 'package:flutter/material.dart';
import 'package:frontend/components/home_navbar.dart';
import 'package:frontend/models/startup.dart';
import 'package:frontend/components/filter_button.dart';
import 'package:frontend/controllers/catalogo_controller.dart';
import 'package:frontend/pages/dashboard_page.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  int _currentIndex = 0;
  final Startup startupExemplo = Startup(
    name: 'VizioAI',
    description: 'O futuro da acessibilidade na navegação na internet',
    contributedCapital: 15000.00,
    issuedTokens: 1000,
    startupState: .nova,
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
    _startups.add(startupExemplo);
    _startups.add(startupExemplo);
    _startups.add(startupExemplo);
    _startups.add(startupExemplo);
    _startups.add(startupExemplo);
    _startups.add(startupExemplo);
    _startups.add(startupExemplo);
    _startups.add(startupExemplo);
    _startups.add(startupExemplo);
  }

  //Future<void> _navigateToStartup() async { // Função para ir para pagina de startup
  //
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo de Startups'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 2,
        shadowColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros', textAlign: .left),
            const SizedBox(height: 6),
            Container(
              height: 48,
              margin: EdgeInsets.only(bottom: 10),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    data: 'Em Desenvolvimento',
                    isPressed: _selectedFilter == StartupState.development,
                    onPressed: () => _toggleFilter(StartupState.development),
                    icon: Icons.science,
                    iconBackgroundColor: Color(0xFFF77F43),
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    data: 'Em Expansão',
                    isPressed: _selectedFilter == StartupState.expansion,
                    onPressed: () => _toggleFilter(StartupState.expansion),
                    icon: Icons.public,
                    iconBackgroundColor: Color(0xFF5759E0),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _startups.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma Startup Disponível',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _startups.length,
                      itemBuilder: (context, index) {
                        final startup = _startups[index];
                        return Card(
                          color: const Color(0xFFFFFFFF),
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(
                              color: Color(0xFFCACACA),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        startup.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(startup.description),
                                      Text(
                                        'Tokens emitidos: ${startup.issuedTokens}',
                                      ),
                                    ],
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: .centerLeft,
                                    padding: EdgeInsets.only(
                                      left: 15,
                                      top: 2,
                                      right: 0,
                                      bottom: 2,
                                    ),
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Color(0xff7AE058),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                      ),
                                    ),
                                    child: Icon(
                                      getStartupStateIcon(startup),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeNavbar(
        currentIndex: _currentIndex,
        onIndexChanged: (int index) {
          if (index == _currentIndex) return;
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DashboardPage()),
            );
          } else if (index != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pagina ainda não foi implementada')),
            );
          }
        },
      ),
    );
  }
}
