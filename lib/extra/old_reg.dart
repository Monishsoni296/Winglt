// class RegistrationScreen extends StatefulWidget {
//   @override
//   _RegistrationScreenState createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends State<RegistrationScreen> {
//   final _auth = FirebaseAuth.instance;
//   late String email;
//   late String password;
//   bool showSpinner = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         actions: <Widget>[
//           IconButton(
//               icon: const Icon(Icons.close_rounded),
//               onPressed: () {
//                 Navigator.pop(context);
//               }),
//         ],
//         title: const Text('let\'s get started',
//             style: TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.w900,
//               fontFamily: 'MyCustomFont',
//               fontSize: 35.0,
//             )),
//         backgroundColor: Colors.white,
//       ),
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: ModalProgressHUD(
//           inAsyncCall: showSpinner,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 const Flexible(
//                   child: Logo(),
//                 ),
//                 const SizedBox(
//                   height: 48.0,
//                 ),
//                 TextField(
//                   keyboardType: TextInputType.emailAddress,
//                   onChanged: (value) {
//                     email = value;
//                   },
//                   decoration:
//                       inputDecoration('Enter your email', Colors.blueAccent),
//                 ),
//                 const SizedBox(
//                   height: 8.0,
//                 ),
//                 TextField(
//                   obscureText: true,
//                   onChanged: (value) {
//                     password = value;
//                   },
//                   decoration: inputDecoration(
//                       'Enter strong password', Colors.blueAccent),
//                 ),
//                 const SizedBox(
//                   height: 24.0,
//                 ),
//                 NavButton(
//                     buttonText: 'Register',
//                     onPressed: () async {
//                       setState(() {
//                         showSpinner = true;
//                       });
//                       try {
//                         final newUser =
//                             await _auth.createUserWithEmailAndPassword(
//                                 email: email, password: password);
//                         if (newUser != Null) {
//                           _firestore.collection('users').add({'email': email});
//                           Navigator.pushNamed(context, '/contact');
//                         }
//                         setState(() {
//                           showSpinner = false;
//                         });
//                         final snackBar = SnackBar(
//                           /// need to set following properties for best effect of awesome_snackbar_content
//                           elevation: 0,
//                           behavior: SnackBarBehavior.floating,
//                           backgroundColor: const Color.fromARGB(0, 233, 6, 6),
//                           content: AwesomeSnackbarContent(
//                             title: "Hello!",
//                             message: 'welcome to BuzzChat',

//                             /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
//                             contentType: ContentType.warning,
//                           ),
//                         );
//                         ScaffoldMessenger.of(context)
//                           ..hideCurrentSnackBar()
//                           ..showSnackBar(snackBar as SnackBar);
//                       } on FirebaseAuthException catch (e) {
//                         print("firevaseException");
//                         print(e.message);
//                       } catch (e) {
//                         print(e);
//                       }
//                     },
//                     colour: Colors.amber),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
