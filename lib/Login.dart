import 'package:winglt/phoneAuth.dart';
import 'package:winglt/screens/login_screen.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                bottom: const TabBar(tabs: [
                  Tab(icon: Icon(Icons.phone)),
                  Tab(icon: Icon(Icons.email))
                ]),
                title: const Text('Login', style: TextStyle(fontSize: 35)),
              ),
              body: const TabBarView(
                children: [PhoneAuth(), SimpleLoginScreen()],
              ),
            )));
  }
}
