import 'package:flutter/material.dart';
import 'package:shop_app/services/authentication.dart';
import 'package:shop_app/services/firestore.dart';

import '../models/product.dart';

class EditProductPage extends StatefulWidget {
  static const routeName = '/edit-product';

  const EditProductPage({super.key});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _key = GlobalKey<FormState>();
  var _isInit = true;
  var _isLoading = false;
  Map<String, String> updatedProduct = {
    'id': '',
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlController.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Product? product = ModalRoute.of(context)?.settings.arguments as Product?;
      if (product != null) {
        updatedProduct['id'] = product.id;
        updatedProduct['title'] = product.title;
        updatedProduct['description'] = product.description;
        updatedProduct['price'] = product.price.toString();
        updatedProduct['imageUrl'] = product.imageUrl;
        _imageUrlController.text = updatedProduct['imageUrl'] as String;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.removeListener(_updateImageUrl);
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!_imageUrlController.text.startsWith('http') &&
          !_imageUrlController.text.startsWith('https')) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm(
      ScaffoldMessengerState scaffold, NavigatorState navigator) async {
    if (!_key.currentState!.validate()) {
      return;
    }
    _key.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if ((updatedProduct['id'] as String).isEmpty) {
      try {
        await Firestore().addProduct(Product(
          updatedProduct['title'] as String,
          updatedProduct['description'] as String,
          double.parse(updatedProduct['price']!),
          updatedProduct['imageUrl'] as String,
          Authentication().uid,
          '',
        ));
        scaffold.showSnackBar(const SnackBar(
          content: Center(
            child: Text(
              'Product added successfully',
            ),
          ),
        ));
      } catch (error) {
        scaffold.showSnackBar(const SnackBar(
          content: Center(child: Text('Can\'t add product!')),
        ));
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    } else {
      await Firestore().updateProduct(
          updatedProduct['id'] as String,
          Product(
            updatedProduct['title'] as String,
            updatedProduct['description'] as String,
            double.parse(updatedProduct['price']!),
            updatedProduct['imageUrl'] as String,
            Authentication().uid,
            updatedProduct['id'] as String,
          ));
      scaffold.showSnackBar(const SnackBar(
        content: Center(
          child: Text(
            'Product updated successfully',
          ),
        ),
      ));
    }
    setState(() {
      _isLoading = false;
    });
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: () =>
                _saveForm(ScaffoldMessenger.of(context), Navigator.of(context)),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8),
              child: Form(
                key: _key,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: updatedProduct['title'],
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_priceFocusNode),
                        validator: (value) {
                          if (value == null) {
                            return 'Field can\'t be empty!';
                          }
                          if (value.isEmpty) {
                            return 'Field can\'t be empty!';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          if (newValue != null) {
                            updatedProduct['title'] = newValue;
                          }
                        },
                      ),
                      TextFormField(
                        initialValue: updatedProduct['price'],
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode),
                        focusNode: _priceFocusNode,
                        validator: (value) {
                          if (value == null) {
                            return 'Field can\'t be empty!';
                          }
                          if (value.isEmpty) {
                            return 'Field can\'t be empty!';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Enter a number!';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Price should be greater than zero!';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          if (newValue != null) {
                            updatedProduct['price'] = newValue;
                          }
                        },
                      ),
                      TextFormField(
                        initialValue: updatedProduct['description'],
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value == null) {
                            return 'Field can\'t be empty!';
                          }
                          if (value.isEmpty) {
                            return 'Field can\'t be empty!';
                          }
                          if (value.length <= 10) {
                            return 'Description length should be greater than 10!';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          if (newValue != null) {
                            updatedProduct['description'] = newValue;
                          }
                        },
                      ),
                      Row(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? const Text('Add image url!')
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'imageUrl'),
                              keyboardType: TextInputType.url,
                              controller: _imageUrlController,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _saveForm(
                                  ScaffoldMessenger.of(context),
                                  Navigator.of(context)),
                              validator: (value) {
                                if (value == null) {
                                  return 'Field can\'t be empty!';
                                }
                                if (value.isEmpty) {
                                  return 'Field can\'t be empty!';
                                }
                                if ((!_imageUrlController.text
                                        .startsWith('http') &&
                                    !_imageUrlController.text
                                        .startsWith('https'))) {
                                  return 'Enter a valid image url!';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                if (newValue != null) {
                                  updatedProduct['imageUrl'] = newValue;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
