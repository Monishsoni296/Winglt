import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import 'auth_service.dart';

final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  bool _toggle = true;
  final _phoneNumberController = TextEditingController(text: '+91');
  final pinController = TextEditingController();
  late String _verificationId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: _toggle
            ? buildNumber()
            : FractionallySizedBox(widthFactor: 1, child: buildPinPut()));
  }

  bool isLoading = false; // for google auth circularProgressIndicator

  Widget buildNumber() {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: ListView(
        children: [
          SizedBox(height: screenHeight * .12),
          const Text(
            'Welcome,',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenHeight * .01),
          Text(
            'Easy Sign-In with Phone',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black.withOpacity(.6),
            ),
          ),
          SizedBox(height: screenHeight * .12),
          TextField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _sendOTP();
              setState(() {
                _toggle = !_toggle;
              });
            },
            child: const Text('Send OTP'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                isLoading = !isLoading;
              });
              try {
                AuthService().signInWithGoogle();
              } catch (e) {
                print(e);
              }
            },
            icon: const Image(
                width: 24.0, // Adjust image width
                height: 24.0,
                image: AssetImage('assets/Google.svg')),
            label: const Text('Continue with Google'),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20), // Adjust padding
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(height: 5),
          if (isLoading)
            Container(width: 260, child: const LinearProgressIndicator()),
        ],
      ),
    ));
  }

  Future<void> _sendOTP() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: _phoneNumberController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
        // Handle successful sign-in
        print('Signed in successfully!');
        const snackBar = SnackBar(content: Text('Logged in successfully!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _toggle = !_toggle;
        });
        print('Verification failed: ${e.message}');
        var snackBar = SnackBar(content: Text(e.message!));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // Handle verification failure
      },
      codeSent: (verificationId, resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  Widget buildPinPut() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text('Verifying',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30)),
            const SizedBox(height: 20),
            const Text('Enter received code'),
            const SizedBox(height: 20),
            Container(width: 260, child: const LinearProgressIndicator()),
            const SizedBox(height: 50),
            Pinput(
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
              controller: pinController,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              onSubmitted: (pin) async {
                final FirebaseAuth auth = FirebaseAuth.instance;
                final PhoneAuthCredential credential =
                    PhoneAuthProvider.credential(
                  verificationId: _verificationId,
                  smsCode: pin,
                );
                try {
                  await auth.signInWithCredential(credential);
                  print('Signed in with PhoneAuthCredential!');
                  const snackBar = SnackBar(content: Text('Signed In!'));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } catch (e) {
                  print('pinput' + '$e');
                  setState(() {
                    _toggle = !_toggle;
                  });
                  var message = e.toString();
                  var snackBar = SnackBar(content: Text(message));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
