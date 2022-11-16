import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:friends_chat/screens/join_room.dart';
import 'package:friends_chat/screens/login.dart';

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
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white
        ),
        initialRoute: LoginScreen.id,
        routes: {
          JoinRoomScreen.id: (_) => const JoinRoomScreen(),
          LoginScreen.id: (_) => const LoginScreen(),
        },
      ),
    );
  }
}

