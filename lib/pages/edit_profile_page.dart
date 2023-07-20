import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/app_drawer.dart';

class EditProfilePage extends StatefulWidget {
  static const routeName = '/edit-profile';

  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _controller = TextEditingController();
  File? file;
  bool loading = false;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    user.displayName != null ? _controller.text = user.displayName! : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      drawer: const AppDrawer(selected: 3),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (image == null) {
                              return;
                            }
                            setState(() {
                              file = File(image.path);
                            });
                          },
                          child: file == null
                              ? (user.photoURL == null
                                  ? const CircleAvatar(
                                      radius: 40,
                                      backgroundImage: NetworkImage(
                                          'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png'),
                                    )
                                  : CircleAvatar(
                                      radius: 40,
                                      backgroundImage:
                                          NetworkImage(user.photoURL!),
                                    ))
                              : CircleAvatar(
                                  radius: 40,
                                  backgroundImage: FileImage(file!),
                                ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _controller,
                          decoration:
                              const InputDecoration(labelText: 'Your name'),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.cyan.shade500),
                            foregroundColor:
                                const MaterialStatePropertyAll(Colors.white),
                          ),
                          onPressed: () async {
                            if (file == null && user.photoURL == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Select a profile image.')));
                              return;
                            }
                            if (_controller.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Please enter your name.')));
                              return;
                            }
                            setState(() {
                              loading = true;
                            });
                            try {
                              file == null
                                  ? null
                                  : await FirebaseStorage.instance
                                      .ref()
                                      .child(user.uid)
                                      .putFile(file!);
                              await user.updateDisplayName(_controller.text);
                              await user.updatePhotoURL(await FirebaseStorage
                                  .instance
                                  .ref()
                                  .child(user.uid)
                                  .getDownloadURL());
                            } catch (e) {
                              Fluttertoast.showToast(msg: e.toString());
                            }
                            setState(() {
                              loading = false;
                            });
                            Fluttertoast.showToast(
                                msg: 'Profile updated successfully :)');
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
