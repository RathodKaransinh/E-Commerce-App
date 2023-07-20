import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/pages/auth_checker.dart';
import 'package:shop_app/pages/cart_page.dart';
import 'package:shop_app/pages/edit_product_page.dart';
import 'package:shop_app/pages/edit_profile_page.dart';
import 'package:shop_app/pages/manage_products.dart';
import 'package:shop_app/pages/orders_page.dart';
import 'package:shop_app/pages/product_detail_page.dart';
import 'package:shop_app/pages/product_overview_page.dart';
import './helpers/themes.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: textTheme,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan.shade500),
        // pageTransitionsTheme: PageTransitionsTheme(
        //   builders: {
        //     TargetPlatform.android: CustomTransitions(),
        //     TargetPlatform.iOS: CustomTransitions(),
        //   },
        // ),
      ),
      home: const AuthChecker(),
      routes: {
        ProductOverviewPage.routeName: (context) => const ProductOverviewPage(),
        ProductDetailPage.routeName: (context) => const ProductDetailPage(),
        CartPage.routeName: (context) => const CartPage(),
        OrdersPage.routeName: (context) => const OrdersPage(),
        ManageProducts.routeName: (context) => const ManageProducts(),
        EditProductPage.routeName: (context) => const EditProductPage(),
        EditProfilePage.routeName: (context) => const EditProfilePage(),
      },
    );
  }
}
