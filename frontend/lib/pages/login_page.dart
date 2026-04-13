import 'package:flutter/material.dart';
import 'recuperar_senha.dart'; // 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Bem vindo!',
                style: TextStyle(
                  fontFamily: "inter",
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Color(0xFF5759E0),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Faça o Login para continuar',
                style: TextStyle(
                  fontFamily: 'inter',
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, 
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    //Log-in logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5759E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Log-in',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    // função para recuperar senha
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecuperarSenhaPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Esqueci minha senha',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF5759E0), fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Não tenho uma conta? Cadastre-se',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'inter',
                    color: Color(0xFF1E1E1E),
                    fontSize: 14,
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