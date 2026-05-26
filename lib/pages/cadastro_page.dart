import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/controllers/cadastro_controller.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/services/signup_services.dart';
import 'package:frontend/utils/cpf_formatter.dart';
import 'package:frontend/utils/phone_formatter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _controller = SigninController();
  final _signUpService = SignUpService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _handleCadastro() async {
    // Validar o formulário antes de enviar
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    UserModel user = UserModel(
      name: _controller.nameController.text,
      email: _controller.emailController.text,
      cpf: _controller.cpfController.text,
      password: _controller.passwordController.text,
      phoneNumber: _controller.phoneController.text,
      birthDate: _controller.birthDateController.text,
    );
    try {
      await _signUpService.signUpUser(user);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = 'Erro ao registrar';

      if (e.code == 'email-already-in-use') {
        errorMessage = 'Este email já está cadastrado';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Senha muito fraca. Use pelo menos 6 caracteres';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email inválido';
      } else if (e.code == 'phone-number-already-exists') {
        errorMessage = 'Este telefone já está cadastrado';
      } else {
        errorMessage = e.message ?? 'Erro ao registrar';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Erro ao registrar')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 160, horizontal: 16),
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
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 6),
            const Text(
              'Preencha todos os campos para continuar',
              textAlign: .center,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _controller.validateEmail,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                      hintText: 'exemplo@gmail.com',
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _controller.nameController,
                    validator: _controller.validateName,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                      border: OutlineInputBorder(),
                      hintText: 'Nome e Sobrenome',
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    onTap: _pickBirthDate,
                    readOnly: true,
                    controller: _controller.birthDateController,
                    validator: _controller.validateBirthDate,
                    decoration: const InputDecoration(
                      labelText: 'Data de Nascimento',
                      hintText: 'dd/mm/aaaa',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    inputFormatters: [telefoneFormatter],
                    controller: _controller.phoneController,
                    keyboardType: TextInputType.phone,
                    validator: _controller.validatePhone,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      border: OutlineInputBorder(),
                      hintText: '+55 (DDD) XXXXX-XXXX',
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    inputFormatters: [cpfFormatter],
                    controller: _controller.cpfController,
                    keyboardType: TextInputType.number,
                    validator: _controller.validateCPF,
                    decoration: const InputDecoration(
                      labelText: 'CPF',
                      border: OutlineInputBorder(),
                      hintText: '000.000.000-00',
                    ),
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _controller.passwordController,
                    obscureText: true,
                    validator: _controller.validatePassword,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                      hint: Text('********'),
                    ),
                  ),
                  Text(
                    'Sua senha deve conter: no mínimo 8 caracteres, no máximo 16 caracteres, uma letra maíuscula, uma letra minúscula, um número, um caractére especial',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            _handleCadastro();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isLoading ? 'Cadastrando...' : 'Cadastrar-se',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Row(
                crossAxisAlignment: .center,
                children: [
                  Text(
                    'Já tem uma conta?',
                    style: TextStyle(color: Colors.black, fontSize: 14),
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
                      style: TextStyle(color: Colors.indigo, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
