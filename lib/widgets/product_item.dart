import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/providers/firestore_provider.dart';

import '../models/product.dart';
import '../pages/product_detail_page.dart';
import '../providers/products_provider.dart';

class ProductItem extends ConsumerWidget {
  const ProductItem(
    this.prodList,
    this.favorites, {
    super.key,
    required this.product,
  });

  final Product product;
  final List<Product> prodList;
  final List<dynamic> favorites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(firestoreProvider);

    Future.delayed(const Duration(seconds: 3)).then((value) =>
        ref.read(productsNotifierProvider.notifier).addProducts(prodList));
    final messenger = ScaffoldMessenger.of(context);

    return GridTile(
      footer: GridTileBar(
        title: Text(
          product.title,
        ),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
        leading: IconButton(
          onPressed: () async => await db.toggleFavorite(product.id),
          icon: favorites.contains(product.id)
              ? (const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ))
              : (const Icon(
                  Icons.favorite_border,
                )),
        ),
        trailing: IconButton(
          onPressed: () async {
            await db.addToCart(product.id);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: const Text(
                  'Item added to cart',
                ),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () async =>
                      await db.decreaseProdQuantityFromCart(product.id),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          },
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            ProductDetailPage.routeName,
            arguments: product,
          );
        },
        child: Hero(
          tag: product.id,
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/images/product-placeholder.png',
            image: product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
