import 'package:flutter/material.dart';
import 'package:friends_chat/screens/login.dart';

Future<void> main() async{ runApp(MyApp());}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white
      ),
      home: LoginScreen(),
    );
  }
}

