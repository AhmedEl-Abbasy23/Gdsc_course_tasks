import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:note_app/tasks_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'add_task.dart';

bool isLogin = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    isLogin = true;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: !isLogin ? '/' : '/tasks',
      // initialRoute:'/',
      routes: {
        '/': (BuildContext context) => const MyHomePage(),
        '/tasks': (BuildContext context) => const TasksScreen(),
        '/addTask': (BuildContext context) => const AddTaskScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  final _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFE4775),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 400.0),
              const Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Text(
                  'Hello there,\nwelcome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                  ),
                ),
              ),
              const SizedBox(height: 150.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await signInWithGoogle().then((credential) {
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(credential.user!.uid)
                            .set({
                          'email': credential.user!.email,
                          'uid': credential.user!.uid,
                        });
                        Navigator.pushReplacementNamed(context, '/tasks');
                        print(credential.user!.uid);
                      }).catchError((error) {
                        print(error.toString());
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 35.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                        ),
                      ),
                      child: SvgPicture.asset(
                        'assets/images/google.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
