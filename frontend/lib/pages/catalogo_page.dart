import 'package:flutter/material.dart';
import 'package:frontend/classes/startup.dart';
import 'package:frontend/controllers/catalogo_controller.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final Startup startupExemplo = Startup(
    name: 'VizioAI',
    description: 'O futuro da acessibilidade na navegação na internet',
    contributedCapital: 15000.00,
    issuedTokens: 1000,
    startupState: .nova,
  );
  final List<Startup> _startups = [];

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
          children: [
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
    );
  }
}
