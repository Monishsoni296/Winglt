// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _auth = FirebaseAuth.instance;
//   late String email;
//   late String password;
//   bool showSpinner = false;

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: ListView(
//           children: [
//             SizedBox(height: screenHeight * .12),
//             const Text(
//               'Welcome,',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: screenHeight * .01),
//             Text(
//               'Sign in to continue!',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.black.withOpacity(.6),
//               ),
//             ),
//             SizedBox(height: screenHeight * .12),
//             InputField(
//               onChanged: (value) {
//                 setState(() {
//                   email = value;
//                 });
//               },
//               labelText: 'Email',
//               errorText: emailError,
//               keyboardType: TextInputType.emailAddress,
//               textInputAction: TextInputAction.next,
//               autoFocus: true,
//             ),
//             SizedBox(height: screenHeight * .025),
//             SizedBox(height: screenHeight * .12),
//             TextField(
//               keyboardType: TextInputType.emailAddress,
//               onChanged: (value) {
//                 email = value;
//               },
//               decoration: inputDecoration('Enter your email', Colors.black),
//             ),
//             const SizedBox(
//               height: 8.0,
//             ),
//             TextField(
//               obscureText: true,
//               onChanged: (value) {
//                 password = value;
//               },
//               decoration: inputDecoration('Enter password', Colors.black),
//             ),
//             const SizedBox(
//               height: 24.0,
//             ),
//             NavButton(
//                 buttonText: 'Login',
//                 onPressed: () async {
//                   try {
//                     final user = await _auth.signInWithEmailAndPassword(
//                         email: email, password: password);
//                     if (user != Null) {
//                       Navigator.pushNamed(context, '/contact');
//                     }
//                   } on FirebaseAuthException catch (e) {
//                     print("firevaseException");
//                     print(e.message);
//                   } catch (e) {
//                     print("Error");
//                     print(e);
//                   }
//                 },
//                 colour: Colors.blue),
//             SquareTile(
//               imgPath: 'assets/Google.svg',
//               onTap: () => AuthService().signInWithGoogle(),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SquareTile extends StatelessWidget {
//   final String imgPath;
//   final Function()? onTap;
//   SquareTile({super.key, required this.imgPath, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         child: Image.asset(imgPath, height: 50),
//       ),
//     );
//   }
// }
