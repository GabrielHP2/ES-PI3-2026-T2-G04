// Lucas Leonel - RA: 25015188
// Gabriel Hespanholeto
// 25004669
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Autenticacao2FAPage extends StatefulWidget {
  final MultiFactorResolver resolver;
  const Autenticacao2FAPage({super.key, required this.resolver});

  @override
  State<Autenticacao2FAPage> createState() => _Autenticacao2FAPageState();
}

class _Autenticacao2FAPageState extends State<Autenticacao2FAPage> {
  final _codigoController = TextEditingController();
  final _smsFormKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSendingCode = false;
  String? _verificationId;
  String? _errorMessage;
  PhoneMultiFactorInfo? _phoneHint;

  void _showSnack(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Future<void> _sendSmsCode() async {
    final phoneHints = widget.resolver.hints.whereType<PhoneMultiFactorInfo>();
    if (phoneHints.isEmpty) {
      setState(() {
        _errorMessage =
            'Nenhum fator de telefone disponível para concluir o login.';
      });
      return;
    }

    _phoneHint = phoneHints.first;

    setState(() {
      _isSendingCode = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: widget.resolver.session,
        multiFactorInfo: _phoneHint!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await widget.resolver.resolveSignIn(
              PhoneMultiFactorGenerator.getAssertion(credential),
            );
          } on FirebaseAuthException catch (e) {
            if (!mounted) return;
            _showSnack('Falha ao concluir o 2FA: ${e.message ?? e.code}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _errorMessage = e.message ?? e.code;
          });
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message ?? e.code;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSendingCode = false;
        });
      }
    }
  }

  Future<void> signIn() async {
    final smsCode = _codigoController.text.trim();
    final verificationId = _verificationId?.trim() ?? '';

    if (verificationId.isEmpty) {
      _showSnack('Aguarde o envio do código SMS para continuar.');
      return;
    }

    if (smsCode.length != 6) {
      _showSnack('Digite os 6 dígitos enviados por SMS.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      await widget.resolver.resolveSignIn(
        PhoneMultiFactorGenerator.getAssertion(credential),
      );
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? e.code);
    } catch (e) {
      _showSnack(e.toString());
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
    _codigoController.dispose();
    super.dispose(); // limpa
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _sendSmsCode();
      }
    });
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
                'Insira o código de 6 dígitos enviado por SMS.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'inter',
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 32),
              Form(
                key: _smsFormKey,
                child: TextField(
                  controller: _codigoController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Código 2FA',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isSendingCode)
                      ? null
                      : () async {
                          await signIn();
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5759E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isLoading
                        ? 'Verificando...'
                        : _isSendingCode
                        ? 'Enviando SMS...'
                        : 'Verificar',
                    style: const TextStyle(
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
