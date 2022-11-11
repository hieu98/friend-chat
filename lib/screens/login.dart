import 'package:flutter/material.dart';
import 'package:friends_chat/screens/join_room.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => JoinRoomScreen(),));
                  }, icon: Icon(Icons.add))
            ],
          ),
          body: Center(
            child: Container(
              child: IconButton(
                onPressed: (){
                    print('Login Google');
                },
                icon: Icon(Icons.g_mobiledata),
              ),
            ),
          ),
        )
    );
  }
}
