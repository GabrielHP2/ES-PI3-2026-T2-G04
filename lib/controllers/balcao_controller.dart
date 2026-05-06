// Gabriel Hespanholeto Maziero 25004669

import 'package:cloud_functions/cloud_functions.dart';

class BalcaoController {
  
  // Busca startups
  Future<List<dynamic>> buscarTokens() async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('NOME DA FUNC');
      final result = await callable.call();
      
      // Conversão
      return result.data as List<dynamic>; 
    } catch (e) {
      print('Erro ao buscar os tokens no FB: $e'); // <-- caso necessario alterar o print !!
      return [];
    }
  }

  // Compra de tokens
  Future<bool> comprarToken(String ticker, int quantidade) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('NOME DA FUNC');
      
      // parametros na func
      await callable.call({
        'ticker': ticker,
        'quantidade': quantidade,
      });
      
      return true; // sucesso
    } catch (e) {
      print('Erro na compra: $e'); // <-- caso necessario alterar o print !!
      return false; // deu erro
    }
  }
}