import 'package:flutter/material.dart';

// Gabriel Hespanholeto
// 25004669

class Autenticacao2FAPage extends StatefulWidget {
  const Autenticacao2FAPage({super.key});

  @override
  State<Autenticacao2FAPage> createState() => _Autenticacao2FAPageState();
}

class _Autenticacao2FAPageState extends State<Autenticacao2FAPage> {
  final _codigoController = TextEditingController();

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose(); // limpa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () {
            Navigator.pop(context);
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
                'Segurança 2FA',
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
                'Insira o código de 6 dígitos gerado pelo seu aplicativo de autenticação.',
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
                controller: _codigoController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: const InputDecoration(
                  labelText: 'Código 2FA',
                  border: OutlineInputBorder(),
                  counterText: "", 
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // vlidação 2fa
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5759E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Verificar',
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