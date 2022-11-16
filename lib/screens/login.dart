import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friends_chat/screens/join_room.dart';
import 'package:friends_chat/screens/list_room.dart';
import 'package:friends_chat/screens/room_chat.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  static const id = 'login_screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  FirebaseAuth auth = FirebaseAuth.instance;
  late FirebaseFirestore firebaseFirestore;
  User? user;

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final UserCredential userCredential =
    await auth.signInWithCredential(credential);

    user = userCredential.user;

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }


  @override
  void initState() {
    super.initState();
    user =  auth.currentUser;
    if(user != null){
      Future(()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ListRoomChat(user: user!,))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Center(
            child: Container(
              child: IconButton(
                onPressed: () async{
                  await signInWithGoogle();
                  if(user != null){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ListRoomChat(user: user!,)));
                  }
                },
                icon: Icon(Icons.g_mobiledata),
              ),
            ),
          ),
        )
    );
  }
}
