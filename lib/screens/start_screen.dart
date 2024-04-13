import 'dart:async';
import 'package:winglt/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late final LocalAuthentication auth;

  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
    Timer(const Duration(seconds: 4), () {
      _authenticate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.teal[400],
        body: SafeArea(
          child: Container(
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text('Winglt',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40.0,
                          fontWeight: FontWeight.w800)),
                ),
                // Expanded(
                //   child: AnimatedTextKit(
                //     animatedTexts: [
                //       RotateAnimatedText('CHAT',
                //           textStyle: const TextStyle(
                //             fontSize: 50.0,
                //             fontWeight: FontWeight.w800,
                //             color: Colors.white,
                //           )),
                //     ],
                //     isRepeatingAnimation: true,
                //     totalRepeatCount: 100,
                //     pause: const Duration(milliseconds: 700),
                //   ),
                // ),
              ],
            ),
          ),
        ));
  }

  Future<void> _getAvailableBiometrics() async {
    await auth.getAvailableBiometrics();
    if (!mounted) {
      return;
    }
  }

  Future<void> _authenticate() async {
    print("authenticating");
    try {
      bool authComplete = await auth.authenticate(
        localizedReason: 'localizedReason',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      setState(() {
        if (authComplete) {
          Navigator.of(context).push(_createRoute());
        }
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const AuthGate(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 1000),
  );
}
