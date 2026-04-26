import 'package:frontend/classes/user.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> SignUpService(SignUpUser user) async {
  final functionUrl =
      'https://southamerica-east1-mescla-invest-fff3b.cloudfunctions.net/signUp';

  try {
    final response = await http.post(
      Uri.parse(functionUrl),
      headers: {'Content-Type': 'application/json'},
      body: {
        'name': user.name,
        'phoneNumber': user.phoneNumber,
        'email': user.email,
        'birthDate': user.birthDate,
        'password': user.password,
        'cpf': user.cpf,
      },
    );

    final status = response.statusCode;
    final responseMessage = response.body.trim();

    if (status == 201) {
      return {
        'success': true,
        'statusCode': status,
        'message': responseMessage.isNotEmpty
            ? responseMessage
            : 'Usuário cadastrado com sucesso',
      };
    }

    return {
      'success': false,
      'statusCode': status,
      'message': responseMessage.isNotEmpty
          ? responseMessage
          : 'Falha ao realizar cadastro',
    };
  } catch (_) {
    return {
      'success': false,
      'statusCode': 0,
      'message': 'Erro de conexão ao realizar cadastro',
    };
  }
}
