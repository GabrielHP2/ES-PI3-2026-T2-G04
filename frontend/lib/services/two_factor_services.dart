import 'package:firebase_auth/firebase_auth.dart';

Future<void> activateSMS2FA(
  String password,
  Future<String?> Function() requestSmsCode,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('Usuário não autenticado');
  if (user.phoneNumber == null || user.phoneNumber!.isEmpty) {
    throw Exception('Telefone do usuário indisponível');
  }

  // Reautenticar com email e senha
  try {
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-mismatch') {
      throw Exception(
        'A senha fornecida não corresponde ao usuário atual. Verifique sua senha.',
      );
    } else if (e.code == 'wrong-password') {
      throw Exception('Senha incorreta. Tente novamente.');
    } else if (e.code == 'user-not-found') {
      throw Exception('Usuário não encontrado. Faça login novamente.');
    }
    throw Exception('Erro ao autenticar: ${e.message}');
  }

  // Obter sessão multifator
  final multifactorSession = await user.multiFactor.getSession();
  String? verificationId;
  FirebaseAuthException? verificationFailure;

  // Verificar número de telefone com reCAPTCHA
  // O reCAPTCHA será exibido automaticamente no iOS
  try {
    await FirebaseAuth.instance.verifyPhoneNumber(
      multiFactorSession: multifactorSession,
      phoneNumber: user.phoneNumber!,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Callback de verificação automática (SMS auto-retrieval)
        final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
        await user.multiFactor.enroll(
          assertion,
          displayName: 'Celular principal',
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailure = e;
      },
      codeSent: (String verificationIdFromServer, int? forceResendingToken) {
        // Callback disparado quando o SMS é enviado (após reCAPTCHA)
        verificationId = verificationIdFromServer;
      },
      codeAutoRetrievalTimeout: (String verificationIdFromServer) {
        // Fallback se o SMS não for recuperado automaticamente
        verificationId = verificationIdFromServer;
      },
    );
  } catch (e) {
    throw Exception('Erro ao enviar SMS: $e');
  }

  if (verificationFailure != null) {
    final code = verificationFailure!.code;
    final message = verificationFailure!.message ?? 'Falha desconhecida';

    if (code == 'app-not-authorized') {
      throw Exception(
        'Este app não está autorizado no Firebase Authentication. Confira package name, SHA-1 e SHA-256 no Firebase Console. [$message]',
      );
    }

    throw Exception('Erro de verificação: $code - $message');
  }

  // Validar se o código foi enviado
  if (verificationId == null || verificationId!.isEmpty) {
    throw Exception(
      'Não foi possível enviar o código SMS. Verifique se o número está correto.',
    );
  }

  // Solicitar código SMS ao usuário
  final smsCode = await requestSmsCode();
  if (smsCode == null || smsCode.trim().length != 6) {
    throw Exception('Código SMS inválido. Deve conter 6 dígitos.');
  }

  // Verificar e inscrever no 2FA
  try {
    final phoneCredential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: smsCode.trim(),
    );
    final assertion = PhoneMultiFactorGenerator.getAssertion(phoneCredential);
    await user.multiFactor.enroll(assertion, displayName: 'Celular principal');
  } on FirebaseAuthException catch (e) {
    throw Exception('Erro ao ativar 2FA: ${e.message}');
  }
}
