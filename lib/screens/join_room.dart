import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friends_chat/screens/room_chat.dart';
import 'package:friends_chat/services/group_provider.dart';

import '../utils/utils.dart';

class JoinRoomScreen extends StatefulWidget {
  static const id = 'joinscreen';
  const JoinRoomScreen({Key? key}) : super(key: key);

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  var code = "";
  final _messageController = TextEditingController();
  static const _char =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random random = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _char.codeUnitAt(random.nextInt(_char.length))));

  @override
  void initState() {
    // TODO: implement initState
    _messageController.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: GestureDetector(
          onTap: (){
            Utils.unFocusTextField(context: context);
          },
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
                            setState(() {
                              code = getRandomString(5);
                              GroupProvider.createGroup(groupId: code);
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RoomChat(
                                      codeRoom: code,
                                    )));
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
                                controller: _messageController,
                                textAlign: TextAlign.center,
                              )
                          ),
                          decoration: BoxDecoration(border: Border.all(width: 2)),
                          padding: EdgeInsets.all(10),
                          width: 100,
                          height: 40,
                        ),
                        TextButton(
                            onPressed: () {
                              Utils.unFocusTextField(context: context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RoomChat(
                                            codeRoom: _messageController.text,
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
      ),
        )
    );
  }
}
