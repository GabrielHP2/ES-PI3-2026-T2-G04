import 'package:flutter/material.dart';
import 'package:frontend/controllers/cadastro_controller.dart';
import 'package:frontend/pages/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _controller = SigninController();
  bool _isSubmitting = false;

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
    if (_isSubmitting) return false;

    setState(() {
      _isSubmitting = true;
    });

    final isCadastroDone = await _controller.cadastrar();
    if (!mounted) return false;
    try {
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
          content: Text('Cadastro feito!', style: TextStyle(color: Colors.red)),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return true;
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
                onPressed: _isSubmitting
                    ? null
                    : () {
                        _handleCadastro();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5759E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isSubmitting ? 'Cadastrando...' : 'Cadastrar-se',
                  style: const TextStyle(color: Colors.white),
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
