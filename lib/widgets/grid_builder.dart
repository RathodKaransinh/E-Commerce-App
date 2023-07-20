import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/providers/firestore_provider.dart';

import '../widgets/product_item.dart';

class GridBuilder extends ConsumerStatefulWidget {
  final bool showFavoritesOnly;

  const GridBuilder({
    super.key,
    required this.showFavoritesOnly,
  });

  @override
  ConsumerState<GridBuilder> createState() => _GridBuilderState();
}

class _GridBuilderState extends ConsumerState<GridBuilder> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final asyncProducts = ref.watch(productsProvider);
    final asyncfavorites = ref.watch(userDataProvider);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: asyncProducts.when(
        data: (data) {
          final prodList = data.docs.map((DocumentSnapshot snap) {
            Map<String, dynamic> data = snap.data()! as Map<String, dynamic>;
            return Product(
              data['title'],
              data['description'],
              data['price'] as double,
              data['imageUrl'],
              data['creatorId'],
              snap.id,
            );
          }).toList();

          var tbdList = prodList;
          List<dynamic> favorites = [];

          asyncfavorites.when(
            data: (data) {
              data.data() != null
                  ? favorites = data.data()!['favorites'] as List<dynamic>
                  : favorites = [];

              widget.showFavoritesOnly
                  ? tbdList.removeWhere(
                      (element) => !(favorites.contains(element.id)))
                  : null;

              setState(() {
                _isLoading = false;
              });
            },
            error: (error, stackTrace) =>
                Fluttertoast.showToast(msg: error.toString()),
            loading: () {
              setState(() {
                _isLoading = true;
              });
            },
          );

          return _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      child: ProductItem(prodList, favorites,
                          product: tbdList[index]),
                    );
                  },
                  itemCount: tbdList.length);
        },
        error: (e, _) => Center(child: Text(e.toString())),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
