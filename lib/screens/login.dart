import 'package:flutter/material.dart';
import 'package:friends_chat/screens/list_room.dart';
import 'package:friends_chat/services/AuthService.dart';

class LoginScreen extends StatefulWidget {
  static const id = 'login_screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  initState() {
    super.initState();
    if(AuthService.check()){
      Future(()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ListRoomChat(user: AuthService.user!,))));
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
                  await AuthService.signInWithGoogle();
                  if(AuthService.check()){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ListRoomChat(user: AuthService.user!,)));
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
