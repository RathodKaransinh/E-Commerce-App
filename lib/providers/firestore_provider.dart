import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/services/firestore.dart';

final firestoreProvider = Provider<Firestore>((ref) {
  return Firestore();
});

final productsProvider = StreamProvider<QuerySnapshot>((ref) {
  return ref.read(firestoreProvider).products;
});

final userDataProvider =
    StreamProvider<DocumentSnapshot<Map<String, dynamic>>>((ref) {
  return ref.read(firestoreProvider).userData;
});
