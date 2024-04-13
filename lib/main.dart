import 'package:winglt/forgetPass.dart';
import 'package:winglt/profile.dart';
import 'package:winglt/screens/contacts.dart';
import 'package:winglt/screens/login_screen.dart';
import 'package:winglt/screens/registration_screen.dart';
import 'package:winglt/screens/start_screen.dart';
import 'package:winglt/screens/welcome_screen.dart';
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
