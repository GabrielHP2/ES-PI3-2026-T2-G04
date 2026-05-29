// João Pedro Panza Mainieri - 25006642;
import 'dart:async';

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
  final verificationIdCompleter = Completer<String?>();

  // Verificar número de telefone com reCAPTCHA
  // O reCAPTCHA será exibido automaticamente no iOS
  try {
    unawaited(
      FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: multifactorSession,
        phoneNumber: user.phoneNumber!,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final assertion = PhoneMultiFactorGenerator.getAssertion(
              credential,
            );
            await user.multiFactor.enroll(
              assertion,
              displayName: 'Celular principal',
            );
            if (!verificationIdCompleter.isCompleted) {
              verificationIdCompleter.complete(null);
            }
          } catch (e) {
            if (!verificationIdCompleter.isCompleted) {
              verificationIdCompleter.completeError(e);
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!verificationIdCompleter.isCompleted) {
            verificationIdCompleter.completeError(e);
          }
        },
        codeSent: (String verificationIdFromServer, int? forceResendingToken) {
          if (!verificationIdCompleter.isCompleted) {
            verificationIdCompleter.complete(verificationIdFromServer);
          }
        },
        codeAutoRetrievalTimeout: (String verificationIdFromServer) {
          if (!verificationIdCompleter.isCompleted) {
            verificationIdCompleter.complete(verificationIdFromServer);
          }
        },
      ),
    );

    final verificationId = await verificationIdCompleter.future.timeout(
      const Duration(seconds: 150),
      onTimeout: () {
        throw Exception(
          'O envio do SMS demorou mais do que o esperado. Tente novamente e conclua o desafio de verificação, se ele aparecer.',
        );
      },
    );

    if (verificationId == null || verificationId.isEmpty) {
      return;
    }

    // Solicitar código SMS ao usuário
    final smsCode = await requestSmsCode();
    if (smsCode == null || smsCode.trim().length != 6) {
      throw Exception('Código SMS inválido. Deve conter 6 dígitos.');
    }

    // Verificar e inscrever no 2FA
    try {
      final phoneCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      final assertion = PhoneMultiFactorGenerator.getAssertion(phoneCredential);
      await user.multiFactor.enroll(
        assertion,
        displayName: 'Celular principal',
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Erro ao ativar 2FA: ${e.message}');
    }
  } catch (e) {
    if (e is FirebaseAuthException) {
      final code = e.code;
      final message = e.message ?? 'Falha desconhecida';

      if (code == 'app-not-authorized') {
        throw Exception(
          'Este app não está autorizado no Firebase Authentication. Confira package name, SHA-1 e SHA-256 no Firebase Console. [$message]',
        );
      }

      throw Exception('Erro de verificação: $code - $message');
    }

    rethrow;
  }
}

Future<void> desactivateSMS2FA() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      List<MultiFactorInfo> enrolledFactors = await user.multiFactor
          .getEnrolledFactors();

      if (enrolledFactors.isEmpty) {
        throw Exception("O usuário não possui nenhum 2FA ativo.");
      }

      // 2. Encontre o fator de telefone (ou outro cadastrado)
      final phoneFactor = enrolledFactors.firstWhere(
        (factor) => factor.factorId == 'phone',
        orElse: () => throw Exception("Fator de telefone não encontrado."),
      );

      // 3. O método 'unenroll' fica direto no 'user.multiFactor', e não na lista!
      await user.multiFactor.unenroll(factorUid: phoneFactor.uid);
    }
  } catch (e) {
    if (e is FirebaseAuthException) {
      throw Exception("Erro ao desativar: ${e.message}");
    }
    rethrow;
  }
}
