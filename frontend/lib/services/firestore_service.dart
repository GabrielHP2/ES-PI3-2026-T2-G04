import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final db = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    await db.collection('usuarios').doc(user.uid).set(user.toMap());
  }
}
