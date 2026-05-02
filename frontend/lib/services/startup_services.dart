import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/models/startup.dart';

Future<List<SimplifiedStartup>?> callStartupsCatalog() async {
  try {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
      'startupCatalog',
    );

    final result = await callable.call() as List<SimplifiedStartup>;

    return result;
  } on FirebaseFunctionsException catch (error) {
    print('Error code: ${error.code}');
    print('Error: $error');
    return null;
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
