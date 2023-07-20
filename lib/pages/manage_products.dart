import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/services/authentication.dart';
import 'package:shop_app/services/firestore.dart';

import '../models/product.dart';
import '../widgets/app_drawer.dart';

class ManageProducts extends StatelessWidget {
  static const routeName = '/manage-products';

  const ManageProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/edit-product'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(selected: 2),
      body: StreamBuilder(
        stream: Firestore().products,
        builder: (ctx, snapshot) {
          List<Product> prodList = [];
          if (snapshot.data == null) {
            prodList = [];
          } else {
            final prodData = snapshot.data!.docs.map((DocumentSnapshot snap) {
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

            prodList = prodData
                .where((element) => element.creatorId == Authentication().uid)
                .toList();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: prodList.isEmpty
                  ? Container(
                      margin: const EdgeInsets.only(right: 40, left: 40),
                      height: 50,
                      width: MediaQuery.of(context).size.width - 16,
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade500,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      alignment: Alignment.center,
                      child: TextButton.icon(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/edit-product'),
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Add your product',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          )),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 5,
                        child: ListTile(
                          title: Text(prodList[index].title),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(prodList[index].imageUrl),
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed('/edit-product',
                                          arguments: prodList[index]),
                                  icon: const Icon(Icons.edit),
                                  color: Colors.cyan.shade500,
                                ),
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Are you sure?'),
                                        content: const Text(
                                            'Do yo want to delete the product'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text('No')),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text('YES')),
                                        ],
                                      ),
                                    ).then((value) async {
                                      if (value != null) {
                                        if (value) {
                                          try {
                                            await Firestore().deleteProduct(
                                                prodList[index].id);
                                          } catch (error) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Center(
                                                child: Text(
                                                  'Can\'t delete product',
                                                ),
                                              ),
                                            ));
                                          }
                                        }
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      itemCount: prodList.length,
                    ),
            );
          }
        },
      ),
    );
  }
}
