import 'package:flutter/material.dart';
import 'package:frontend/pages/login_page.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                'Cadastrando sua conta',
                textAlign: .center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color(0xFF5759E0),
                ),
              ),
              SizedBox(height: 6),
              const Text(
                'Preencha todos os campos para continuar',
                textAlign: .center,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              SizedBox(height: 48),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Ir para esqueci minha senha, levar o email
                },
                child: Text(
                  'Esqueci minha senha',
                  textAlign: TextAlign.center, // isso devia estar aqui?
                  style: TextStyle(color: Color(0xFF5759E0), fontSize: 14),
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  //Sign-in logic
                  // 1- validar campos vazios
                  // 2- validar formatos
                  // 3- validar se já existe campos críticos no banco de dados
                  // 4- Confirmar cadastro
                  // 5- cadastrar no banco de dados
                  // 6- feedback para o usuário
                  // 7- Ir para página de log-in
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5759E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Cadastrar-se',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 12),
              Center(
                child: Row(
                  crossAxisAlignment: .center,
                  children: [
                    Text(
                      'Já tem uma conta?',
                      style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Fazer log-in',
                        style: TextStyle(
                          color: Color(0xFF5759E0),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
