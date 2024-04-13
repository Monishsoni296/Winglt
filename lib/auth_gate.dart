import 'package:winglt/Login.dart';
import 'package:winglt/constant.dart';
import 'package:winglt/screens/contacts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // has user logged in or not
            if (snapshot.hasData) {
              return fetchPage();
            } else {
              return const LoginPage();
            }
          }),
    );
  }
}

class fetchPage extends StatefulWidget {
  fetchPage({super.key});

  @override
  State<fetchPage> createState() => _fetchPageState();
}

class _fetchPageState extends State<fetchPage> {
  bool _loadingData = true;

  @override
  void initState() {
    checkDocumentWithID('users', _auth.currentUser?.uid);
    super.initState();
  }

  Future<bool> doesDocumentExistWithID(
      String collectionPath, String idValue) async {
    try {
      final collectionRef =
          FirebaseFirestore.instance.collection(collectionPath);

      final querySnapshot = await collectionRef.get();
      for (var doc in querySnapshot.docs) {
        if (doc.data()['uid'] == idValue) return true;
      }
      return false;
    } catch (e) {
      // Handle potential errors
      print("Error checking document existence: $e");
      return false; // Or throw an exception if preferred
    }
  }

  Future<void> checkDocumentWithID(collectionPath, idValue) async {
    final doesExist = await doesDocumentExistWithID(collectionPath, idValue);
    if (doesExist) {
      print(
          "At least one document in collection $collectionPath has ID $idValue");
    } else {
      print("No documents in collection $collectionPath have ID $idValue");
      addUser(_auth.currentUser);
    }
    setState(() {
      _loadingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return _loadingData
        ? Scaffold(
            body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * .08),
                const Text(
                  'Fetching your details',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * .01),
                Container(width: 260, child: const LinearProgressIndicator()),
              ],
            ),
          ))
        : ContactScreen();
  }
}
