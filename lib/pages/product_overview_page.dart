import 'package:flutter/material.dart';
import '../widgets/grid_builder.dart';
import '../widgets/app_drawer.dart';

class ProductOverviewPage extends StatefulWidget {
  static const routeName = '/product-overview';

  const ProductOverviewPage({super.key});

  @override
  State<ProductOverviewPage> createState() => _ProductOverviewPageState();
}

class _ProductOverviewPageState extends State<ProductOverviewPage> {
  var showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
            icon: const Icon(Icons.shopping_cart),
          ),
          PopupMenuButton(
            onSelected: (int selectedValue) {
              setState(() {
                if (selectedValue == 0) {
                  showFavoritesOnly = true;
                } else {
                  showFavoritesOnly = false;
                }
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 0,
                child: Text('Favorites'),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text('All'),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      drawer: const AppDrawer(selected: 0),
      body: GridBuilder(showFavoritesOnly: showFavoritesOnly),
    );
  }
}
