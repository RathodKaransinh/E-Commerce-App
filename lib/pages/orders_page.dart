import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart.dart';
import '../providers/firestore_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersPage extends ConsumerStatefulWidget {
  static const routeName = '/orders';

  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(userDataProvider);

    final prodList = ref.read(productsNotifierProvider);
    final width = MediaQuery.of(context).size.width - 16;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(selected: 1),
      body: asyncData.when(
        data: (data) {
          if (data.data() == null) {
            return const Center(
              child: Text('No Orders to show'),
            );
          } else {
            final cart = data.data()!['cart'] as List<dynamic>;

            final orderList = cart
                .where((element) => element['isOrdered'] as bool)
                .toList()
                .map((e) => Cart(e['id'] as String, e['quantity'] as int,
                    e['isOrdered'] as bool))
                .toList();

            return orderList.isEmpty
                ? const Center(
                    child: Text('No Orders to show'),
                  )
                : Container(
                    height: height,
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    child: ListView.builder(
                      itemBuilder: (context, index) => OrderItem(
                        order: orderList[index],
                        width: width,
                        product: prodList.firstWhere((element) =>
                            element.id == orderList[index].productId),
                      ),
                      itemCount: orderList.length,
                    ),
                  );
          }
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
