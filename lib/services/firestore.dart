import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/services/authentication.dart';

class Firestore {
  final db = FirebaseFirestore.instance;
  final uid = Authentication().uid;

  Stream<QuerySnapshot<Map<String, dynamic>>> get products =>
      db.collection('products').snapshots();

  Stream<DocumentSnapshot<Map<String, dynamic>>> get userData =>
      db.collection('users').doc(uid).snapshots();

  Future<void> addProduct(Product product) async {
    try {
      await db.collection('products').add(product.toMap());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await db.collection('products').doc(id).delete();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    try {
      await db.collection('products').doc(id).set(product.toMap());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      DocumentSnapshot snap = await db.collection('users').doc(uid).get();

      if (snap.exists) {
        List<dynamic> favorites =
            (snap.data() as Map<String, dynamic>)['favorites'] as List<dynamic>;

        if (favorites.contains(id)) {
          favorites.remove(id);
        } else {
          favorites.add(id);
        }

        await db.collection('users').doc(uid).update({'favorites': favorites});
      } else {
        await db.collection('users').doc(uid).set({
          'favorites': [id],
          'cart': [],
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> addToCart(String id) async {
    try {
      DocumentSnapshot snap = await db.collection('users').doc(uid).get();

      if (snap.exists) {
        var cart =
            (snap.data() as Map<String, dynamic>)['cart'] as List<dynamic>;

        bool flag = false;
        for (var element in cart) {
          if (element['id'] == id) {
            flag = true;
            element['quantity'] = (element['quantity'] as int) + 1;
          }
        }

        if (!flag) {
          cart.add({'id': id, 'quantity': 1, 'isOrdered': false});
        }

        await db.collection('users').doc(uid).update({'cart': cart});
      } else {
        await db.collection('users').doc(uid).set({
          'favorites': [],
          'cart': [
            {'id': id, 'quantity': 1, 'isOrdered': false}
          ]
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> decreaseProdQuantityFromCart(String id) async {
    try {
      DocumentSnapshot snap = await db.collection('users').doc(uid).get();

      final cart =
          (snap.data() as Map<String, dynamic>)['cart'] as List<dynamic>;

      int quantity = 1;

      for (var element in cart) {
        if (element['id'] == id) {
          quantity = element['quantity'] as int;
        }
      }

      if (quantity == 1) {
        cart.removeWhere((element) => element['id'] as String == id);
      } else {
        for (var element in cart) {
          if (element['id'] == id) {
            element['quantity'] = (element['quantity'] as int) - 1;
          }
        }
      }

      await db.collection('users').doc(uid).update({'cart': cart});
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> deleteCartProduct(String id) async {
    try {
      DocumentSnapshot snap = await db.collection('users').doc(uid).get();

      final cart =
          (snap.data() as Map<String, dynamic>)['cart'] as List<dynamic>;

      cart.removeWhere((element) => element['id'] as String == id);

      await db.collection('users').doc(uid).update({'cart': cart});
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> addOrder() async {
    try {
      DocumentSnapshot snap = await db.collection('users').doc(uid).get();

      final cart =
          (snap.data() as Map<String, dynamic>)['cart'] as List<dynamic>;

      for (var element in cart) {
        if (!(element['isOrdered'] as bool)) {
          element['isOrdered'] = true;
        }
      }

      await db.collection('users').doc(uid).update({'cart': cart});
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
