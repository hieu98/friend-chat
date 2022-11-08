import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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
                Container(child: Center(child: Text( code == "" ? "Room Code" : code)), decoration: BoxDecoration(border: Border.all(width: 2,color: Colors.black)), padding:EdgeInsets.all(10), width: 100, height: 40,),
                TextButton(onPressed: (){
                  setState(() {
                    code = getRandomString(5);
                    print(code);
                  });
                }, child: Container(child: Text("Create room"), decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.black)), padding: EdgeInsets.all(5),))
              ],
            ),
          ),
        )
    );
  }
}
