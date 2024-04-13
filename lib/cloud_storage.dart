import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class UploadImagePage extends StatefulWidget {
  const UploadImagePage({Key? key, required this.rid}) : super(key: key);
  final String rid;
  @override
  _UploadImagePageState createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  final _auth = FirebaseAuth.instance;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    getCurrentuser();
  }

  void getCurrentuser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(widget.rid);
        print(loggedInUser?.email);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> uploadImage() async {
    if (_imageFile == null) return;

    final fileName = _imageFile!.path.split('/').last;
    final storageReference = FirebaseStorage.instance.ref().child(fileName);
    try {
      await storageReference.putFile(_imageFile!);
    } on FirebaseException catch (e) {
      // Caught an exception from Firebase.
      print("Failed with error '${e.code}': ${e.message}");
    }
    // final uploadTask = storageReference.putFile(_imageFile!);

    final downloadUrl = await storageReference.getDownloadURL();

    // You can use the downloadUrl to store it in your database or display the image
    print('Image uploaded: $downloadUrl');

    _firestore.collection('messages').add({
      'imgURL': downloadUrl,
      'sender': loggedInUser?.uid,
      'receiver': widget.rid,
      'time': DateTime.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Select Image'),
            ),
            if (_imageFile != null)
              Image.file(_imageFile!, width: 200, height: 200),
            ElevatedButton(
              onPressed: uploadImage,
              child: Text('Upload to Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
