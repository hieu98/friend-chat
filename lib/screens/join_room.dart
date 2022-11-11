import 'dart:math';

import 'package:flutter/material.dart';
import 'package:friends_chat/screens/room_chat.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  var code = "";
  static const _char =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random random = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _char.codeUnitAt(random.nextInt(_char.length))));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RoomChat(
                                    codeRoom: code,
                                  )));
                          setState(() {
                            code = getRandomString(5);
                            print(code);
                          });
                        },
                        child: Container(
                          child: Text("Create room"),
                          decoration: BoxDecoration(border: Border.all(width: 2)),
                          padding: EdgeInsets.all(5),
                        )),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Center(
                            child: TextField(
                              onEditingComplete: () {
                              },
                            )
                        ),
                        decoration: BoxDecoration(border: Border.all(width: 2)),
                        padding: EdgeInsets.all(10),
                        width: 100,
                        height: 40,
                      ),
                      TextButton(
                          onPressed: () {
                            print(code);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RoomChat(
                                          codeRoom: code,
                                        )));
                          },
                          child: Container(
                            child: Text("Join room"),
                            decoration: BoxDecoration(border: Border.all(width: 2)),
                            padding: EdgeInsets.all(5),
                          ))
                    ],
                  ),
                ]
            ),
          ),
      )
    );
  }
}
