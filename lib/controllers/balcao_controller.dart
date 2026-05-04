// Gabriel Hespnholeto Maziero 25004669
import 'dart:convert';
import 'package:http/http.dart' as http;

class BalcaoController {
  final String _baseUrl = 'http://10.0.2.2:3000/api';

  Future<bool> solicitarCompra({required String ticker, required int quantidade}) async {
    try {
      final url = Uri.parse('$_baseUrl/transacao/comprar');

      // jason para o back
      final body = jsonEncode({
        'ticker': ticker,
        'quantidade': quantidade,
        'tipo': 'COMPRA',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // pedido post
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // true se o back responder com sucesso
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
       print('Erro na comunicação com o servidor: $e');
      return false;
    }
  }

  ///  req de venda para o back
  Future<bool> solicitarVenda({required String ticker, required int quantidade}) async {
    try {
      final url = Uri.parse('$_baseUrl/transacao/vender');

      final body = jsonEncode({
        'ticker': ticker,
        'quantidade': quantidade,
        'tipo': 'VENDA',
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}