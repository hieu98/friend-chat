import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'join_room.dart';

class ListRoomChat extends StatefulWidget {
  final User user;

  const ListRoomChat(
      {Key? key,
      required this.user}
      ) : super(key: key);

  @override
  State<ListRoomChat> createState() => _ListRoomChatState();
}

class _ListRoomChatState extends State<ListRoomChat> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text("Chat"),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => JoinRoomScreen()));
                    }, icon: Icon(Icons.add))
              ],
            ),
            body: Container(
              margin: EdgeInsets.only(top: 15),
              child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    CircleAvatar(
                      radius: 15,
                      child: Image.network(widget.user.photoURL!),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Text(widget.user.displayName!),
                    ),
                  ]
                ),
            ),
        )
    );
  }
}
