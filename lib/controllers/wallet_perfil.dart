// Gabriel Hespanholeto Maziero 25004669

import 'dart:developer' as developer;
import 'package:cloud_functions/cloud_functions.dart';

class WalletController {
  
  // Func para buscar o saldo para  a página de perfil atualizar
  Future<double> buscarSaldoReal() async {
    try {
      // Conecta o CF 
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getUserProfile');
      
      // chamada
      final result = await callable.call();
      
      // Extrai o campo do banco
      final double saldoVindoDoBanco = (result.data['saldo'] ?? 0.0).toDouble();
      
      developer.log('Saldo real recuperado: R\$ $saldoVindoDoBanco', name: 'WalletController');
      return saldoVindoDoBanco;

    } catch (e, stackTrace) {
      developer.log('Erro ao buscar saldo real', name: 'WalletController', error: e, stackTrace: stackTrace);
      return 0.0; 
    }
  }
}