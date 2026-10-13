import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getFoodItems() async {
    final doc = await db
        .collection('food_items')
        .doc('food_item')
        .get();

    return doc.data();
  }

  Future<Map<String, dynamic>?> getDrinks() async {
    final doc = await db
        .collection('drinks')
        .doc('drinks')
        .get();

    return doc.data();
  }
}