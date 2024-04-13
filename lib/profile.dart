import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final _auth = FirebaseAuth.instance;
late QueryDocumentSnapshot<Map<String, dynamic>> user;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _toggle = false;
  String profilePic = 'assets/profile.jpg';
  String username = 'null';
  String phone = 'null';
  String email = 'null';

  void updateProfile() {
    if (user['photo'].toString() != 'null') {
      profilePic = user['photo'];
    }
    if (user['name'].toString() != 'null') {
      username = user['name'];
    }
    if (user['phone'].toString() != 'null') {
      phone = user['phone'];
    }
    if (user['email'].toString() != 'null') {
      email = user['email'];
    }
    return;
  }

  Future<void> getUser() async {
    setState(() {
      _toggle = false;
    });
    try {
      final collectionRef = FirebaseFirestore.instance.collection('users');

      final querySnapshot = await collectionRef.get();
      for (var doc in querySnapshot.docs) {
        if (doc.data()['uid'] == _auth.currentUser?.uid) {
          print(doc.data()['email']);
          setState(() {
            user = doc;
            updateProfile();
            _toggle = !_toggle;
          });
          break;
        }
      }
    } catch (e) {
      // Handle potential errors
      print(
          "Error checking document existence: $e"); // Or throw an exception if preferred
    }
    return;
  }

  Future<void> getImage() async {
    File? imageFile;
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    imageFile = File(pickedFile.path);
    final fileName = user['name'] + 'profliePic';
    final storageRef = FirebaseStorage.instance.ref().child(fileName);
    try {
      await storageRef.putFile(imageFile!);
    } on FirebaseException catch (e) {
      print("Failed with error '${e.code}': ${e.message}");
    }

    final downloadUrl = await storageRef.getDownloadURL();
    print('Image uploaded: $downloadUrl');

    // adding image link into database
    try {
      final ref = FirebaseFirestore.instance.collection("users").doc(user.id);
      ref.update({"photo": downloadUrl}).then((value) {
        getUser();
        print('Profile pic updated successfully!');
      }, onError: (e) => print("Error updating document $e"));
    } catch (error) {
      print('Error updating profile pic:');
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(),
        body: _toggle
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListView(
                  children: [
                    SizedBox(height: screenHeight * .08),
                    imageProfile(),
                    SizedBox(height: screenHeight * .01),
                    inputR('name', username),
                    inputR('email', email),
                    inputR('phone', phone),
                    Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            _auth.signOut();
                          },
                          child: const Text('Logout',
                              style:
                                  TextStyle(color: Colors.red, fontSize: 18)),
                        )),
                  ],
                ),
              )
            : loadingScreen(screenHeight: screenHeight));
  }

  Padding inputR(String text1, String text2) {
    final TextEditingController _textController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text1,
            style: const TextStyle(fontSize: 15),
          ),
          GestureDetector(
            onTap: () {
              // Show CupertinoAlertDialog with input field
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: Text(text1),
                  content: Column(
                    children: [
                      CupertinoTextField(
                        controller: _textController,
                        placeholder: "Enter your text here",
                      ),
                    ],
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('Close'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoDialogAction(
                      child: const Text('Update'),
                      onPressed: () {
                        final newText = _textController.text;
                        try {
                          final ref = FirebaseFirestore.instance
                              .collection("users")
                              .doc(user.id);
                          ref.update({text1: newText}).then((value) {
                            getUser();
                            print(user.data());
                            print('$text1 updated');
                          },
                              onError: (e) =>
                                  print("Error updating document $e"));
                        } catch (error) {
                          print('Error updating $text1');
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
            child: Text(text2,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          )
        ],
      ),
    );
  }

  Widget imageProfile() {
    return Center(
        child: Stack(alignment: Alignment.center, children: <Widget>[
      CircleAvatar(
        radius: 100.0,
        backgroundImage: profilePic != 'null'
            ? NetworkImage(profilePic) as ImageProvider
            : AssetImage('asset/profile.jpg'),
      ),
      Positioned(
          bottom: 20.0,
          right: 30.0,
          child: InkWell(
              onTap: getImage,
              child: const Icon(Icons.edit, size: 28.0, color: Colors.blue)))
    ]));
  }
}

class loadingScreen extends StatelessWidget {
  const loadingScreen({
    super.key,
    required this.screenHeight,
  });

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(height: screenHeight * .08),
        const Text(
          'fetching your data',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * .01),
        Container(
          width: 300,
          child: LinearProgressIndicator(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ]),
    );
  }
}

class inputRow extends StatefulWidget {
  const inputRow({
    super.key,
    required this.text1,
    required this.text2,
  });

  final String text1;
  final String text2;

  @override
  State<inputRow> createState() => _inputRowState();
}

class _inputRowState extends State<inputRow> {
  final TextEditingController _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.text1,
            style: const TextStyle(fontSize: 15),
          ),
          GestureDetector(
            onTap: () {
              // Show CupertinoAlertDialog with input field
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: Text(widget.text1),
                  content: Column(
                    children: [
                      CupertinoTextField(
                        controller: _textController,
                        placeholder: "Enter your text here",
                      ),
                    ],
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('Close'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoDialogAction(
                      child: const Text('Update'),
                      onPressed: () {
                        final newText = _textController.text;
                        try {
                          final ref = FirebaseFirestore.instance
                              .collection("users")
                              .doc(user.id);
                          ref.update({'name': newText}).then((value) {
                            print('Profile pic updated successfully!');
                          },
                              onError: (e) =>
                                  print("Error updating document $e"));
                        } catch (error) {
                          print('Error updating profile pic:');
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
            child: Text(widget.text2,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          )
        ],
      ),
    );
  }
}
