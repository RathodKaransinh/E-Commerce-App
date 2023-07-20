import 'package:flutter/material.dart';
import 'package:shop_app/services/firestore.dart';

import '../models/cart.dart';
import '../models/product.dart';

class OrderItem extends StatelessWidget {
  final double width;
  final Cart order;
  final Product product;

  const OrderItem(
      {super.key,
      required this.width,
      required this.order,
      required this.product});

  @override
  Widget build(BuildContext context) {
    var scaffold = ScaffoldMessenger.of(context);
    return Container(
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
                  product.imageUrl,
                  width: width * 0.30,
                  height: 110,
                  fit: BoxFit.cover,
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  '${order.quantity}x',
                  style: TextStyle(
                    color: Colors.cyan.shade500,
                    fontSize: 20,
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
                  product.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '\u{20B9}${product.price * order.quantity}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Are you sure?'),
                        content: const Text('Do you want to cancel the order?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text(
                              'No',
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text(
                              'Yes',
                            ),
                          ),
                        ],
                      ),
                    ).then((value) async {
                      if (value != null) {
                        if (value) {
                          try {
                            await Firestore()
                                .deleteCartProduct(order.productId);
                          } catch (error) {
                            scaffold.showSnackBar(const SnackBar(
                                content: Center(
                              child: Text('Can\'t delete order!'),
                            )));
                          }
                        }
                      }
                    });
                  },
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all(Colors.cyan.shade500)),
                  child: const Text('Cancel Order'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
