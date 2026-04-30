import 'package:flutter/material.dart';
import 'package:frontend/models/startup.dart';

class PaginaDetalhada extends StatefulWidget{
  @override 
  State<PaginaDetalhada> createState()=> _PaginaDetalhadaState();
}

class _PaginaDetalhadaState extends State<PaginaDetalhada> { 
  Widget _buildPlaceholderLine({double width = double.infinity}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 6,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

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
          child: Icon(
            Icons.play_arrow,
            size: 50,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: ''),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'NOME DA STARTUP',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Em operação',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                ],
              ),
            ),

            // VIDEO PLACEHOLDER
            _buildVideoPlaceholder(),

            // ACTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:[
                  IconButton(
                    icon: const Icon(Icons.attach_money),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaginaDetalhada(),//tem que trocar para a tela real 
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility_off),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaginaDetalhada(),//tem que trocar para a tela real
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(),

            // ICON MENU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Icon(Icons.menu_book),
                  Icon(Icons.groups),
                  Icon(Icons.chat_bubble_outline),
                  Icon(Icons.list),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Sobre a startup',
                      style: TextStyle(color:Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text('Essa startup atua no setor de tecnologia financeira, oferecendo soluções modernas para pagamentos digitais e gestão financeira.',),
                    SizedBox(height: 12),
                    Text('Equipe',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'A equipe é formada por desenvolvedores, designers e especialistas em negócios com experiência no mercado.',
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Produto',
                      style: TextStyle(color:Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'O principal produto é uma plataforma digital que facilita transações e análise financeira em tempo real.',
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Mercado',
                      style: TextStyle(color:Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}