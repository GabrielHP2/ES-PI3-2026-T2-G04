import 'package:cloud_functions/cloud_functions.dart';
import 'package:frontend/models/startup.dart';

final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
  region: 'southamerica-east1',
);

Future<List<SimplifiedStartup>?> callStartupsCatalog() async {
  try {
    HttpsCallable callable = _functions.httpsCallable('startupCatalog');

    final result = await callable.call();

    // result.data virá como uma List dinâmica do Firebase
    final List data = result.data as List;

    // Aqui usamos o factory SimplifiedStartup.fromMap para converter cada item
    return data
        .map(
          (item) => SimplifiedStartup.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();
  } on FirebaseFunctionsException catch (e) {
    print(
      'Erro ao carregar catálogo: code=${e.code}, message=${e.message}, details=${e.details}',
    );
    return null;
  } catch (e) {
    print('Erro ao carregar catálogo: $e');
    return null;
  }
}

Future<Startup?> callStartupDetail(String startupId) async {
  try {
    HttpsCallable callable = _functions.httpsCallable('getStartupDetails');

    // Passando o ID como parâmetro para a função
    final result = await callable.call({'id': startupId});

    // Usamos o factory Startup.fromMap para o objeto único
    return Startup.fromMap(Map<String, dynamic>.from(result.data));
  } on FirebaseFunctionsException catch (e) {
    print(
      'Erro ao carregar detalhes: code=${e.code}, message=${e.message}, details=${e.details}',
    );
    return null;
  } catch (e) {
    print('Erro ao carregar detalhes: $e');
    return null;
  }
}
