import 'package:winglt/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance;

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: Logo(),
            ),
            const SizedBox(
              height: 48.0,
            ),
            NavButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              buttonText: 'Log In',
              colour: Colors.blue,
            ),
            NavButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              buttonText: 'Register',
              colour: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }
}
