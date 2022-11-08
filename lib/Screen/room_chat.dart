import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoomChat extends StatefulWidget {
  const RoomChat({Key? key}) : super(key: key);

  @override
  State<RoomChat> createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Container(

            ),
          ),
        )
    );
  }
}
