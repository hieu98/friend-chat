import 'package:flutter/material.dart';
import 'package:friends_chat/screens/list_room.dart';
import '../providers/auth_provider.dart';

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
    if(AuthProvider.check()){
      Future(()=> Navigator.push(context, MaterialPageRoute(builder: (context) => ListRoomChat(user: AuthProvider.user!,))));
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
                  await AuthProvider.signInWithGoogle();
                  if(AuthProvider.check()){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ListRoomChat(user: AuthProvider.user!,)));
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
