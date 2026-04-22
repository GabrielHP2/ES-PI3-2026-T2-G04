import 'package:flutter/material.dart';

class Startup {
  final String name;

  Startup({required this.name});
}

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final Startup startupExemplo = Startup(name: 'VizioAI');
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
      body: _startups.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: Text(
                  'Nenhuma Startup Disponível',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _startups.length,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final startup = _startups[index];
                return Card(
                  color: const Color(0xFFFFFFFF),
                  elevation: 5,
                  margin: EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFCACACA), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          startup.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Descrição startup'),
                        Text('Setor de Atuação'),
                        Text('Tokens emitidos:'),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5759E0),
                          ),
                          onPressed: () {}, // Chama _navigateToStartup(index)?
                          child: Text(
                            'ver mais',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
