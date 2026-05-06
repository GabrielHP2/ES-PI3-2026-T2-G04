// Gabriel Hespanholeto Maziero 25004669

import 'dart:developer' as developer;
import 'package:cloud_functions/cloud_functions.dart';

class BalcaoController {
  
  // Func para busca e processamento das startups
  Future<List<Map<String, dynamic>>> buscarTokens() async {
    try {
      // Call da API
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('tokensCatalog');
      final result = await callable.call();
      
      final List<dynamic> startupsBrutas = result.data['startups'];
      List<Map<String, dynamic>> tokensProntosParaTela = [];

      // Traduz do node para flutter
      for (var startup in startupsBrutas) {
        double precoAtual = (startup['last_price'] ?? 0).toDouble();
        double variacaoCalculada = 0.0;
        
        List<dynamic> historico = startup['price_history'] ?? [];

        // Calcula se subiu e desceu
        if (historico.isNotEmpty) {
          double precoAntigo = (historico.first['price'] ?? precoAtual).toDouble();
          if (precoAntigo > 0) {
            variacaoCalculada = ((precoAtual - precoAntigo) / precoAntigo) * 100;
          }
        }

        // Monta depois da tradução
        tokensProntosParaTela.add({
          'ticker': startup['token_symbol'],
          'nome': startup['name'],
          'precoAtual': precoAtual,
          'variacao': variacaoCalculada,
        });
      }
      
      developer.log('Tokens processados com sucesso', name: 'BalcaoController.buscarTokens');
      return tokensProntosParaTela; 

    } catch (e, stackTrace) {
      developer.log('Erro ao buscar', name: 'BalcaoController.buscarTokens', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // -----------------------------

  // !!!>>>> AQUI PODE SER A FUNCAO DE COMPRA  <<<<<

  
}