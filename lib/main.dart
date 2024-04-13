import 'package:buzz_chat/forgetPass.dart';
import 'package:buzz_chat/profile.dart';
import 'package:buzz_chat/screens/contacts.dart';
import 'package:buzz_chat/screens/login_screen.dart';
import 'package:buzz_chat/screens/registration_screen.dart';
import 'package:buzz_chat/screens/start_screen.dart';
import 'package:buzz_chat/screens/welcome_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  runApp(BuzzChat());
}

class BuzzChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => StartScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => SimpleLoginScreen(),
        '/register': (context) => SimpleRegisterScreen(),
        '/contact': (context) => ContactScreen(),
        '/forget': (context) => forgetPassword(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
