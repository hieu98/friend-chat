import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/login.dart';

class AuthService {
  static GoogleSignIn googleSignIn= GoogleSignIn();
  static String _collection = "users";
  static FirebaseAuth auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static User? user;

  static Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final UserCredential userCredential =
        await auth.signInWithCredential(credential);

    user = userCredential.user;
  }

  static Future checkUser() async {
    user = auth.currentUser;
    if (user != null) {
      final QuerySnapshot result = await _firestore
          .collection(_collection)
          .where('id', isEqualTo: user?.uid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
        _firestore.collection(_collection).doc(user?.uid).set({
          'nickName': user?.displayName,
          'photoUrl': user?.photoURL,
          'id': user?.uid
        });
      }
    }
  }

  static Future signOut() async {
    await auth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

  }

  static bool check() {
    checkUser();
    return user != null;
  }
}
