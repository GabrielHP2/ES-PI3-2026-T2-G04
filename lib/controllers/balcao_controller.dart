// Gabriel Hespanholeto Maziero 25004669

import 'dart:developer' as developer;
import 'package:cloud_functions/cloud_functions.dart';

class BalcaoController {
  
  // funcão de busca startups
  Future<List<dynamic>> buscarTokens() async {
    try {

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('tokensCatalog');
      final result = await callable.call();
      
      developer.log('Tokens listados com sucesso', name: 'BalcaoController.buscarTokens');
      
      return result.data['startups'] as List<dynamic>; 

    } catch (e, stackTrace) {
      developer.log('Erro ao buscar', name: 'BalcaoController.buscarTokens', error: e, stackTrace: stackTrace);
      return [];
    }
  }

// -----------------------------

    // !!!>>>> AQUI PODE SER A FUNCAO DE COMPRA  <<<<<
}
