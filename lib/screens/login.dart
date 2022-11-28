import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:friends_chat/screens/list_room.dart';
import 'package:friends_chat/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
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
    Utils.askPermission([Permission.notification]);
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
              height: 50,
              child: SignInButton(
                padding:EdgeInsets.only(left: 30),
                Buttons.GoogleDark,
                onPressed: () async{
                  await AuthProvider.signInWithGoogle();
                  if(AuthProvider.check()){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ListRoomChat(user: AuthProvider.user!,)));
                  }
                },
              ),
            ),
          ),
        )
    );
  }
}
