// João Pedro Panza Mainieri - 25006642;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend/models/token.dart';
import 'package:frontend/models/transactions.dart';
import 'package:frontend/models/wallet.dart';
import 'package:frontend/utils/decimal_service.dart';
import 'package:frontend/services/token_services.dart';

final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
  region: 'southamerica-east1',
);

Future<WalletBalance?> callWalletBalance() async {
  try {
    final HttpsCallable callable = _functions.httpsCallable('walletBalance');
    final result = await callable.call();

    if (result.data == null) return null;
    final data = Map<String, dynamic>.from(result.data as Map);

    final balance = WalletBalance.fromMap(data);
    return balance;
  } catch (e) {
    print('Erro ao carregar o saldo da carteira: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> callWalletDeposit(
  String depositQuantity,
  PaymentType paymentMethod,
) async {
  try {
    final HttpsCallable callable = _functions.httpsCallable('walletDeposit');

    final result = await callable.call({
      'depositQuantity': depositQuantity,
      'paymentMethod': paymentMethod.name,
    });

    return result.data as Map<String, dynamic>;
  } on FirebaseFunctionsException catch (e) {
    print(
      'Erro ao depositar o saldo na carteira: code=${e.code}, message=${e.message}, details=${e.details}',
    );
    return null;
  } catch (e) {
    print('Erro ao depositar o saldo na carteira: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> callWalletWithdraw(
  String withdrawQuantity,
) async {
  try {
    final HttpsCallable callable = _functions.httpsCallable('walletWithdraw');
    final result = await callable.call({'withdrawQuantity': withdrawQuantity});

    return result.data as Map<String, dynamic>;
  } on FirebaseFunctionsException catch (e) {
    print(
      'Erro ao sacar o saldo da carteira: code=${e.code}, message=${e.message}, details=${e.details}',
    );
    return null;
  } catch (e) {
    print('Erro ao sacar o saldo da carteira: $e');
    return null;
  }
}

Future<List<TransactionModel>> callWalletTransactions() async {
  try {
    final HttpsCallable callable = _functions.httpsCallable(
      'walletTransaction',
    );
    final result = await callable.call();

    if (result.data == null) return [];

    // Converte para List de forma segura
    final List rawData = result.data as List;

    return rawData.map((e) {
      // Garante que cada item da lista seja um Map<String, dynamic>
      final mapItem = Map<String, dynamic>.from(e as Map);
      return TransactionModel.fromMap(mapItem);
    }).toList();
  } catch (e) {
    print('Erro ao carregar as transações: $e');
    return [];
  }
}

Future<Decimal> getWalletValue() async {
  // Preciso somar o preço atual * quantidade de token de todos os tokens que o usuário possui
  TokenWalletBalance? tokenWalletBalance = await callWalletHoldings();
  if (tokenWalletBalance == null) return toDecimal('0');

  Decimal walletValue = toDecimal('0');

  for (final h in tokenWalletBalance.holdings) {
    final Token? token = await buscarTokenPorStartupId(h.startupId);
    if (token == null) {
      throw Error();
    }
    walletValue =
        walletValue + toDecimal(h.tokenBalance.toString()) * token.precoAtual;
  }

  return walletValue;
}

Future<TokenWalletBalance?> callWalletHoldings() async {
  try {
    final HttpsCallable callable = _functions.httpsCallable('walletHoldings');

    final result = await callable.call();

    if (result.data == null) {
      print('Erro ao carregar os tokens da carteira: resposta vazia da função');
      return null;
    }

    final data = Map<String, dynamic>.from(result.data as Map);
    final walletHoldings = TokenWalletBalance.fromMap(data);
    return walletHoldings;
  } on FirebaseFunctionsException catch (e) {
    print(
      'Erro ao carregar os tokens da carteira: code=${e.code}, message=${e.message}, details=${e.details}',
    );
    return null;
  } catch (e) {
    print('Erro ao carregar os tokens da carteira: $e');
    return null;
  }
}
