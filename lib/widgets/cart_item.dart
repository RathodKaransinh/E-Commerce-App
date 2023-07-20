import 'package:flutter/material.dart';
import 'package:shop_app/services/firestore.dart';

import '../models/cart.dart';
import '../models/product.dart';

class CartItem extends StatelessWidget {
  final Product cartItem;
  final Cart cart;
  final double width;

  const CartItem({
    super.key,
    required this.cartItem,
    required this.cart,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(cartItem.id),
      onDismissed: (_) async =>
          await Firestore().deleteCartProduct(cartItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        decoration: const BoxDecoration(color: Colors.red),
        child: const Icon(size: 50, Icons.delete),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: Colors.blueGrey.shade50),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: width * 0.03),
        height: 180,
        width: width,
        child: Row(
          children: [
            SizedBox(
              width: width * 0.35,
              child: Column(
                children: [
                  Image.network(
                    cartItem.imageUrl,
                    width: width * 0.30,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5),
                            ),
                          ),
                          child: InkWell(
                            onTap: () async {
                              await Firestore()
                                  .decreaseProdQuantityFromCart(cartItem.id);
                            },
                            child: (cart.quantity == 1)
                                ? const Icon(Icons.delete)
                                : const Icon(Icons.remove),
                          ),
                        ),
                        Text(
                          '${cart.quantity}',
                          style: TextStyle(
                            color: Colors.cyan.shade500,
                            fontSize: 20,
                          ),
                        ),
                        Container(
                          width: width * 0.1,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              Firestore().addToCart(cartItem.id);
                            },
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: width * 0.04,
            ),
            SizedBox(
              width: width * 0.55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    maxLines: 3,
                    cartItem.description,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '\u{20B9}${cartItem.price}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
