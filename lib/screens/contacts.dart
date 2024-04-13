import 'package:winglt/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: CircleAvatar(
              child: Image.asset('assets/profile.jpg'),
            )),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.power_settings_new_outlined),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        backgroundColor: Colors.white,
      ),
      body: SafeArea(child: UserInformation()),
    );
  }
}

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});

  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .where('uid', isNotEqualTo: _auth.currentUser?.uid)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length, // Specify the number of items
          itemBuilder: (context, index) {
            DocumentSnapshot document = snapshot.data!.docs[index];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: data['photo'] != null
                    ? NetworkImage(data['photo']!)
                    : AssetImage('assets/profile.jpg') as ImageProvider,
              ),
              title: Text(getName(data)),
              subtitle: Text(data['email']),
              selectedTileColor: Colors.teal[100],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatScreen(rid: data['uid'], rname: getName(data)),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String getName(Map<String, dynamic> messageDataMap) {
    if (messageDataMap['name'] != null) return messageDataMap['name'];
    if (messageDataMap['phone'] != null) return messageDataMap['phone'];
    if (messageDataMap['email'] != null) return messageDataMap['email'];
    return messageDataMap['name'];
  }
}
