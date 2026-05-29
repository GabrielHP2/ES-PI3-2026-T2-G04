// João Pedro Panza Mainieri - 25006642;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:frontend/models/question.dart';

final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
  region: 'southamerica-east1',
);

Future<List<Question?>> callGetQuestions(
  String startupId,
  bool isPublic,
) async {
  try {
    final HttpsCallable callable = _functions.httpsCallable('getQuestions');

    final result = await callable.call({
      'startup_id': startupId,
      'is_public': isPublic,
    });

    // result.data vem como uma List dinâmica do Firebase
    final List data = result.data as List;

    return data
        .map((e) => Question.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  } on FirebaseFunctionsException catch (e) {
    print(
      'Erro ao carregar perguntas: code=${e.code}, message=${e.message}, details=${e.details}',
    );
    return [];
  } catch (e) {
    print('Erro ao carregar perguntas: $e');
    return [];
  }
}

Future<Map<String, dynamic>?> callSendQuestion(
  String startupId,
  bool isPublic,
  String questionText,
) async {
  try {
    final HttpsCallable callable = _functions.httpsCallable('sendQuestions');
    final result = await callable.call({
      'startup_id': startupId,
      'is_public': isPublic,
      'question_text': questionText,
    });

    final dynamic data = result.data;

    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      // Retorna pelo menos as chaves 'message' e 'question_id' quando disponíveis
      return {
        'message': map['message'] ?? map['msg'] ?? '',
        'question_id': map['question_id'] ?? map['id'] ?? map['questionId'],
      };
    }

    // Se o resultado não for um mapa, retorna o dado cru em uma chave 'data'
    return {'data': data};
  } on FirebaseFunctionsException catch (e) {
    print(
      'Erro ao enviar pergunta: code=${e.code}, message=${e.message}, details=${e.details}',
    );
    return null;
  } catch (e) {
    print('Erro ao enviar pergunta: $e');
    return null;
  }
}
