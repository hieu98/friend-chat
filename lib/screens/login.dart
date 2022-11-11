import 'package:flutter/material.dart';
import 'package:friends_chat/screens/join_room.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Center(
            child: Container(
              child: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => JoinRoomScreen(),));
                },
                icon: Icon(Icons.g_mobiledata),
              ),
            ),
          ),
        )
    );
  }
}
