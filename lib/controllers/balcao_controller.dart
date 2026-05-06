// Gabriel Hespanholeto Maziero 25004669
import 'dart:developer' as developer;
import 'package:cloud_functions/cloud_functions.dart';

final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
  region: 'southamerica-east1',
);

// Func para busca e processamento das startups
Future<List<Map<String, dynamic>>> buscarTokens() async {
  try {
    // Call da API
    final HttpsCallable callable = _functions.httpsCallable('tokensCatalog');
    final result = await callable.call();
    final List<dynamic> startupsBrutas = result.data['startups'];
    List<Map<String, dynamic>> tokensProntosParaTela = [];

    // Traduz do node para flutter
    for (var startup in startupsBrutas) {
      double precoAtual = (startup['last_price'] ?? 0).toDouble();
      double variacaoCalculada = 0.0;

      List<dynamic> historicoRaw = startup['price_history'] ?? [];

      DateTime? parseTimestamp(dynamic value) {
        if (value is int) {
          return DateTime.fromMillisecondsSinceEpoch(value);
        }
        if (value is num) {
          return DateTime.fromMillisecondsSinceEpoch(value.toInt());
        }
        if (value is DateTime) {
          return value;
        }
        if (value != null && value.runtimeType.toString() == 'Timestamp') {
          try {
            final dynamic ts = value;
            return ts.toDate() as DateTime;
          } catch (_) {
            return null;
          }
        }
        return null;
      }

      final List<Map<String, dynamic>> historicoOrdenado =
          historicoRaw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
            ..sort((a, b) {
              final DateTime? ta = parseTimestamp(a['timestamp']);
              final DateTime? tb = parseTimestamp(b['timestamp']);
              if (ta == null && tb == null) return 0;
              if (ta == null) return -1;
              if (tb == null) return 1;
              return ta.compareTo(tb);
            });

      // Extrai só os preços como List<double>
      List<double> historico = historicoOrdenado
          .map((e) => (e['price'] as num).toDouble())
          .toList();

      // Calcula variação diária: último preço antes do início do dia atual.
      if (historicoOrdenado.isNotEmpty) {
        final DateTime now = DateTime.now();
        final DateTime inicioDoDia = DateTime(now.year, now.month, now.day);

        Map<String, dynamic>? ultimoPrecoDiaAnterior;
        for (final item in historicoOrdenado) {
          final DateTime? ts = parseTimestamp(item['timestamp']);
          if (ts != null && ts.isBefore(inicioDoDia)) {
            ultimoPrecoDiaAnterior = item;
          }
        }

        final double precoBase =
            ((ultimoPrecoDiaAnterior?['price'] ?? precoAtual) as num)
                .toDouble();

        if (precoBase > 0) {
          variacaoCalculada = ((precoAtual - precoBase) / precoBase) * 100;
        }
      }

      // Monta depois da tradução
      tokensProntosParaTela.add({
        'token_symbol': startup['token_symbol'],
        'nome': startup['name'],
        'precoAtual': precoAtual,
        'variacao': variacaoCalculada,
        'historico': historico,
      });
    }

    developer.log(
      'Tokens processados com sucesso',
      name: 'BalcaoController.buscarTokens',
    );
    return tokensProntosParaTela;
  } catch (e, stackTrace) {
    print(
      'Erro ao buscar name: buscarTokens() error: $e, stackTrace: $stackTrace,',
    );
    return [];
  }
}
