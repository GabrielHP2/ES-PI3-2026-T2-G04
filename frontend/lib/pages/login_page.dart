import 'package:flutter/material.dart';
import 'package:frontend/pages/auth_2fa.dart';
import 'package:frontend/pages/cadastro_page.dart';
import 'package:frontend/pages/detalhada_page.dart';
import 'package:frontend/pages/home_shell.dart';
import 'package:frontend/pages/recuperar_senha.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 6),
              const Text(
                'Faça o login para continuar',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Colors.black,
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
                  style: TextStyle(color: Colors.indigo, fontSize: 14),
                ),
              ),
              //somente para testes, esse botao será removido
              /*
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaginaDetalhadaNaoInvestidor(),
                    ),
                  );
                },
                child: Text('Ir para detalhes'),
              ),
              */
              //final botao
              
              

              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  //login
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    ); //checa e-mail e senha

                    messenger.hideCurrentSnackBar();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Login feito com sucesso')),
                    );
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeShell()),
                      (route) => false,
                    );
                  } on FirebaseAuthMultiFactorException catch (error) {
                    if (!mounted) return;

                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) =>
                            Autenticacao2FAPage(resolver: error.resolver),
                      ),
                    );
                  } on FirebaseAuthException catch (error) {
                    //casos de erro
                    if (!mounted) return;
                    String mensagemErro =
                        "Erro ao fazer login: $error, Error Code: ${error.code}";
                    if (error.code == 'user-not-found') {
                      mensagemErro = "Usuário não encontrado";
                    } else if (error.code == 'wrong-password') {
                      mensagemErro = "Senha incorreta";
                    } else if (error.code == 'invalid-email') {
                      mensagemErro = "Email inválido";
                    } else if (error.code == 'invalid-credential') {
                      mensagemErro = "Credenciais Inválidas";
                    }
                    messenger.hideCurrentSnackBar();
                    messenger.showSnackBar(
                      SnackBar(content: Text(mensagemErro)),
                    );
                  } catch (error) {
                    if (!mounted) return;

                    debugPrint("Erro inesperado login: $error");
                    messenger.hideCurrentSnackBar();
                    messenger.showSnackBar(
                      SnackBar(content: Text(error.toString())),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
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
              Center(
                child: Row(
                  children: [
                    Text(
                      'Não tem uma conta?',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => SignUpPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Cadastre-se',
                        style: TextStyle(color: Colors.indigo, fontSize: 14),
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
