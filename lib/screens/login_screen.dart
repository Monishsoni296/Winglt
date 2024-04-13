import 'package:winglt/constant.dart';
import 'package:winglt/forgetPass.dart';
import 'package:winglt/screens/registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SimpleLoginScreen extends StatefulWidget {
  final Function(String? email, String? password)? onSubmitted;
  const SimpleLoginScreen({this.onSubmitted, Key? key}) : super(key: key);
  @override
  State<SimpleLoginScreen> createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  final _auth = FirebaseAuth.instance;
  late String email, password;
  String? emailError, passwordError;
  Function(String? email, String? password)? get onSubmitted =>
      widget.onSubmitted;

  @override
  void initState() {
    super.initState();
    email = '';
    password = '';

    emailError = null;
    passwordError = null;
  }

  void resetErrorText() {
    setState(() {
      emailError = null;
      passwordError = null;
    });
  }

  bool validate() {
    resetErrorText();

    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    bool isValid = true;
    if (email.isEmpty || !emailExp.hasMatch(email)) {
      setState(() {
        emailError = 'Email is invalid';
      });
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() {
        passwordError = 'Please enter a password';
      });
      isValid = false;
    }
    return isValid;
  }

  Future<void> submit() async {
    if (validate()) {
      if (onSubmitted != null) {
        onSubmitted!(email, password);
      } else {
        try {
          await _auth.signInWithEmailAndPassword(
              email: email, password: password);
        } on FirebaseAuthException catch (e) {
          print("firevaseException + $e.message");
          var message = 'Invalid credentials';
          message = e.message ?? message;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } catch (e) {
          print("Error + $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error occured')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            SizedBox(height: screenHeight * .08),
            const Text(
              'OR,',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * .01),
            Text(
              'Continue with your email!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black.withOpacity(.6),
              ),
            ),
            SizedBox(height: screenHeight * .12),
            InputField(
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              labelText: 'Email',
              errorText: emailError,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autoFocus: true,
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              onSubmitted: (val) => submit(),
              labelText: 'Password',
              errorText: passwordError,
              obscureText: true,
              textInputAction: TextInputAction.next,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => forgetPassword(),
                  ),
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * .05,
            ),
            FormButton(
              text: 'Log In',
              onPressed: submit,
            ),
            SizedBox(
              height: screenHeight * .05,
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SimpleRegisterScreen(),
                ),
              ),
              child: RichText(
                text: const TextSpan(
                  text: "I'm a new user, ",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
