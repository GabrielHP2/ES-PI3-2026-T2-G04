import 'package:flutter/material.dart';
import 'package:frontend/controllers/cadastro_controller.dart';
import 'package:frontend/pages/login_page.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _controller = SigninController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;

    _controller.setBirthDate(picked);
  }

  Future<bool> _handleCadastro() async {
    final isCadastroDone = await _controller.cadastrar();
    if (!mounted) return false;
    if (!isCadastroDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _controller.errorMessage ?? 'Falha ao cadastrar',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
      return false;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cadastrro Feito!', style: TextStyle(color: Colors.red)),
      ),
    );
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const LoginPage()));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 30.0,
            right: 30.0,
            top: 40.0,
            bottom: 30.0,
          ),
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
                  fontSize: 12,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              SizedBox(height: 24),
              TextField(
                controller: _controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _controller.usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                onTap: _pickBirthDate,
                readOnly: true,
                controller: _controller.birthDateController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  hintText: 'dd/mm/aaaa',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _controller.cpfController,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _controller.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  //Sign-in logic
                  // (x) 1- validar campos vazios
                  // (x) 2- validar formatos
                  // ( ) 3- validar se já existe campos críticos no banco de dados
                  // (x) 4- Confirmar cadastro
                  // ( ) 5- cadastrar no banco de dados
                  // (x) 6- feedback para o usuário
                  // (x) 7- Ir para página de log-in
                  _handleCadastro();
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
