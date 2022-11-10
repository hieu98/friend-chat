import 'package:flutter/material.dart';
import 'dart:math';

import 'package:friends_chat/screens/room_chat.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  var code = "";
  static const _char = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random random = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _char.codeUnitAt(random.nextInt(_char.length))));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(child: Center(child: Text( code == "" ? "Room Code" : code)), decoration: BoxDecoration(border: Border.all(width: 2)), padding:EdgeInsets.all(10), width: 100, height: 40,),
                TextButton(onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RoomChat()
                      )
                  );
                  setState(() {
                    code = getRandomString(5);
                    print(code);
                  });
                }, child: Container(child: Text("Create room"), decoration: BoxDecoration(border: Border.all(width: 2)), padding: EdgeInsets.all(5),))
              ],
            ),
          ),
        )
    );
  }
}
