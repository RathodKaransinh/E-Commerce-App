import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/cart.dart';
import 'package:shop_app/providers/products_provider.dart';

import '../providers/firestore_provider.dart';
import '../widgets/cart_item.dart';

class CartPage extends ConsumerStatefulWidget {
  static const routeName = '/cart';

  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  var _loading = false;
  double subTotal = 0;

  @override
  Widget build(BuildContext context) {
    final db = ref.read(firestoreProvider);
    final asyncData = ref.watch(userDataProvider);
    final prodList = ref.read(productsNotifierProvider);

    double width = MediaQuery.of(context).size.width - 16;
    final scaffold = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: asyncData.when(
        data: (data) {
          List<Cart> cartList = [];

          if (data.data() == null) {
          } else {
            final cart = data.data()!['cart'] as List<dynamic>;

            cartList = cart
                .where((element) => !(element['isOrdered'] as bool))
                .toList()
                .map((e) => Cart(e['id'] as String, e['quantity'] as int,
                    e['isOrdered'] as bool))
                .toList();
          }

          setState(() {
            subTotal = 0;
            for (var element in cartList) {
              final product =
                  prodList.firstWhere((prod) => element.productId == prod.id);
              subTotal += product.price * element.quantity;
            }
          });

          return _loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 10),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 23,
                              ),
                              children: [
                                const TextSpan(text: 'Subtotal '),
                                TextSpan(
                                  text:
                                      '\u{20B9}${subTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(10)),
                            minimumSize: MaterialStateProperty.all(
                                const Size.fromHeight(50)),
                            backgroundColor: MaterialStateProperty.all(
                                Colors.amber.shade500),
                          ),
                          onPressed: () async {
                            if (cartList.isEmpty) {
                              scaffold.showSnackBar(const SnackBar(
                                  content: Center(
                                child: Text('Your cart is empty!'),
                              )));
                            } else {
                              setState(() {
                                _loading = true;
                              });
                              await db.addOrder();
                              setState(() {
                                _loading = false;
                              });
                              scaffold.showSnackBar(const SnackBar(
                                  content: Center(
                                child: Text('Order placed successfully :)'),
                              )));
                            }
                          },
                          child: Text(
                            'Proceed to Buy (${cartList.length} item)',
                            style: const TextStyle(
                              fontSize: 21,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            ...(cartList
                                .map((e) => CartItem(
                                      cartItem: prodList.firstWhere((element) =>
                                          element.id == e.productId),
                                      cart: e,
                                      width: width,
                                    ))
                                .toList())
                          ],
                        ),
                      ],
                    ),
                  ),
                );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, trace) => Center(
          child: Text(e.toString()),
        ),
      ),
    );
  }
}
