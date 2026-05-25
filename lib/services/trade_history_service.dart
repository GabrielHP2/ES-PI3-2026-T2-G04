// Autor: Gabriel Henrique Pacagnelli Pagliato   RA: 25016528

import 'package:cloud_functions/cloud_functions.dart';
import '../models/trade.dart';

import 'dart:developer'; // remover

class TradeHistoryService {

  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  static Future<List<Trade>> fetchTrades() async {

    try {

      final callable = _functions.httpsCallable('tradesHistory');
      final result = await callable();

      final data = Map<String, dynamic>.from(result.data as Map);
      final trades = data['tradesWithSymbols'] as List<dynamic>? ?? const [];

      log('$trades'); // remover

      return trades
        .map((e) => Trade.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    } catch (error) {
      
      print('Erro ao carregar o histórico de trades $error');
      return [];
    }
  }
}