import 'package:flutter/material.dart';
import 'package:frontend/pages/auth_2fa.dart';
import 'package:frontend/pages/cadastro_page.dart';
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
                onPressed: () async {//login
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    ); //checa e-mail e senha
                    Future<void> iniciar2FA() async {
                      final user = FirebaseAuth.instance.currentUser;
                      final phone = user!.phoneNumber;
                      await FirebaseAuth.instance.verifyPhoneNumber(phoneNumber: phone!,verificationCompleted: (credential)
                       async {
                          // Para caso de android: 
                          await FirebaseAuth.instance.signInWithCredential(credential);
                        },
                        verificationFailed: (FirebaseAuthException e) {
                          if (e.code == 'invalid-phone-number') {
                            print('The provided phone number is not valid.');
                          }
                        },
                        codeSent: (String verificationId, int? resendToken) {
                          Navigator.push(context,MaterialPageRoute(builder: (_) => Autenticacao2FAPage(verificationId: verificationId,),
                            ),
                          );
                        },
                        codeAutoRetrievalTimeout: (verificationId) {},
                      );
                    }
                    await iniciar2FA();

                  } on FirebaseAuthException catch (error) {//casos de erro
                    if (!context.mounted) return;
                    String mensagemErro = "Erro ao fazer login";
                    if (error.code == 'user-not-found') {
                      mensagemErro = "Usuário não encontrado";
                    } else if (error.code == 'wrong-password') {
                      mensagemErro = "Senha incorreta";
                    } else if (error.code == 'invalid-email') {
                      mensagemErro = "Email inválido";
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(mensagemErro)),
                    );
                  } catch (error) {
                    if (!context.mounted) return;

                    debugPrint("Erro inesperado login: $error");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error.toString()),
                      ),
                    );
                  }
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
                            builder: (context) => SigninPage(),
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
