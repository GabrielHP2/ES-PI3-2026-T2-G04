import 'package:flutter/material.dart';
import 'package:frontend/pages/auth_2fa.dart';
import 'package:frontend/pages/cadastro_page.dart';
import 'package:frontend/pages/recuperar_senha.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
                'Bem-vindo!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Color(0xFF5759E0),
                ),
              ),
              SizedBox(height: 6),
              const Text(
                'Faça o login para continuar',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecuperarSenhaPage(
                        emailInicial: _emailController.text,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Esqueci minha senha',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF5759E0), fontSize: 14),
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  //Log-in logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5759E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Log-in',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 12),
              //---------------------------------
              // VAI DIREITO PARA A 2FA, É SO TESTE ANTES DO FLUXO
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Autenticacao2FAPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5759E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'TESTE, botao para teste da tela',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 146, 3),
                    fontSize: 16,
                  ),
                ),
              ),

              // -------- TESTE <<< ACABA NESSA LINHA, REMOVER DEPOIS
              SizedBox(height: 12),

              Center(
                child: Row(
                  children: [
                    Text(
                      'Não tem uma conta?',
                      style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const SigninPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Cadastre-se',
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
