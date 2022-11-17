import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:friends_chat/screens/login.dart';
import 'package:friends_chat/utils/utils.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Utils.unFocusTextField(context: context);
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white
        ),
        home: LoginScreen(),
      ),
    );
  }
}

