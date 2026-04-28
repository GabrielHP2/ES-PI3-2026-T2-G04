import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user_model.dart';

class SignUpService {
  final String _functionUrl =
      'https://southamerica-east1-mescla-invest-fff3b.cloudfunctions.net/signUp';

  Future<UserCredential> signUpUser(UserModel user) async {
    try {
      final payload = {
        'name': user.name.trim(),
        'phoneNumber': user.phoneNumber.trim().replaceAll(RegExp(r'\s+'), ''),
        'email': user.email.trim().toLowerCase(),
        'birthDate': user.birthDate.trim(),
        'password': user.password,
        'cpf': user.cpf.replaceAll(RegExp(r'\D'), ''),
      };
      final response = await http.post(
        Uri.parse(_functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        // Faz login para obter o token
        final firebaseAuth = FirebaseAuth.instance;
        final credential = await firebaseAuth.signInWithEmailAndPassword(
          email: payload['email'] as String,
          password: user.password,
        );

        await credential.user?.sendEmailVerification();
        return credential;
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw FirebaseAuthException(
          code: 'sign-up-failed',
          message: error['error']?.toString() ?? 'Erro ao cadastrar',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
