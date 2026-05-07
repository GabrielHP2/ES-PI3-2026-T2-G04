import 'package:cloud_functions/cloud_functions.dart';

final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
  region: 'southamerica-east1',
);

Future<bool> callIsUserInvestor(String startupId) async {
  try {
    final HttpsCallable callable = _functions.httpsCallable('isUserInvestor');

    final result = await callable.call({'startup_id': startupId});

    return result.data as bool;
  } on FirebaseFunctionsException catch (e) {
    print(
      'Erro ao carregar perguntas: code=${e.code}, message=${e.message}, details=${e.details}',
    );
    return false;
  } catch (e) {
    print('Erro ao carregar perguntas: $e');
    return false;
  }
}
