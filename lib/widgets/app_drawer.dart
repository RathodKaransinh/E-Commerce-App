import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/pages/edit_profile_page.dart';

import '../providers/auth_provider.dart';
import '../pages/product_overview_page.dart';
import '../pages/orders_page.dart';
import '../pages/manage_products.dart';

class AppDrawer extends ConsumerStatefulWidget {
  final int selected;

  const AppDrawer({super.key, required this.selected});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  late int _selectedDestination;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    _selectedDestination = widget.selected;
    super.initState();
  }

  void selectDestination(int index) {
    setState(() {
      _selectedDestination = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                user.photoURL == null
                    ? const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png'),
                      )
                    : CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(user.photoURL!),
                      ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    user.displayName == null || user.displayName!.isEmpty
                        ? 'Your Name'
                        : user.displayName!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text('Shop'),
            selected: _selectedDestination == 0,
            onTap: () {
              if (_selectedDestination != 0) {
                selectDestination(0);
                Navigator.of(context)
                    .pushReplacementNamed(ProductOverviewPage.routeName);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: const Text('My Orders'),
            selected: _selectedDestination == 1,
            onTap: () {
              if (_selectedDestination != 1) {
                selectDestination(1);
                Navigator.of(context)
                    .pushReplacementNamed(OrdersPage.routeName);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Manage Products'),
            selected: _selectedDestination == 2,
            onTap: () {
              if (_selectedDestination != 2) {
                selectDestination(2);
                Navigator.of(context)
                    .pushReplacementNamed(ManageProducts.routeName);
              }
            },
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Edit Profile'),
            selected: _selectedDestination == 3,
            onTap: () {
              if (_selectedDestination != 3) {
                selectDestination(3);
                Navigator.of(context)
                    .pushReplacementNamed(EditProfilePage.routeName);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/');
              ref.read(authenticationProvider).signOut();
            },
          ),
        ],
      ),
    );
  }
}
