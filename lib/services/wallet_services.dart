import 'package:cloud_functions/cloud_functions.dart';
import 'package:decimal/decimal.dart';
import 'package:frontend/models/transactions.dart';
import 'package:frontend/models/wallet.dart';
import 'package:frontend/services/decimal_service.dart';

final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
  region: 'southamerica-east1',
);

Future<WalletBalance?> callWalletBalance() async {
  try {
    final HttpsCallable callable = _functions.httpsCallable('walletBalance');

    final result = await callable.call();

    final data = result.data as Map<String, dynamic>;
    final balance = WalletBalance.fromMap(data);
    return balance;
  } on FirebaseFunctionsException catch (e) {
    print(
      'Erro ao carregar o saldo da carteira: code=${e.code}, message=${e.message}, details=${e.details}',
    );
    return null;
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
      'depositQuantity': toDecimal(depositQuantity),
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
    final result = await callable.call({
      'withdrawQuantity': toDecimal(withdrawQuantity),
    });

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

    final List data = result.data as List;

    return data
        .map(
          (e) => TransactionModel.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  } on FirebaseFunctionsException catch (e) {
    print(
      'Erro ao carregar o saldo da carteira: code=${e.code}, message=${e.message}, details=${e.details}',
    );
    return [];
  } catch (e) {
    print('Erro ao carregar o saldo da carteira: $e');
    return [];
  }
}

Future<Decimal> getWalletValue() async {
  // Preciso somar o preço atual * quantidade de token de todos os tokens que o usuário possui

  // function ->

  return toDecimal('0'); // TODO: IMPLEMENTAR!!!
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
