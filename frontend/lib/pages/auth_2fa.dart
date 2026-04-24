import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/pages/catalogo_page.dart';

// Gabriel Hespanholeto
// 25004669

class Autenticacao2FAPage extends StatefulWidget {
  final String verificationId;
  const Autenticacao2FAPage({super.key, required this.verificationId});

  @override
  State<Autenticacao2FAPage> createState() => _Autenticacao2FAPageState();
}

class _Autenticacao2FAPageState extends State<Autenticacao2FAPage> {
  final _codigoController = TextEditingController();
  var code = '';
  Future signIn() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: code,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential).then((
        value,
      ) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => CatalogoPage()),
          (route) => false,
        );
      });
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Ocorreu um erro', e.code);
    } catch (e) {
      Get.snackbar('Ocorreu um erro', e.toString());
    }
  }

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
                'Insira o código de 6 enviado no seu sms.',
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
                onChanged: (value) {
                  setState(() {
                    code = value;
                  });
                },
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
                  onPressed: () async {
                    await signIn();
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
