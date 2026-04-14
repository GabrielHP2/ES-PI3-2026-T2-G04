import 'package:flutter/material.dart';

// Gabriel Hespanholeto Maziero
// 25004669

class RecuperarSenhaPage extends StatefulWidget {
  const RecuperarSenhaPage({super.key});

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () {
            Navigator.pop(context); // Retorna para a tela de Login
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Recuperar Senha',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "inter",
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Color(0xFF5759E0),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Insira seu e-mail cadastrado para receber as instruções de redefinição de senha.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'inter',
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double
                    .infinity, // Faz o botão ocupar toda a largura disponível
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para enviar as instruções para o e-mail
                    // Implementação via Firebase Auth ou API do backend
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5759E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Enviar instruções',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
