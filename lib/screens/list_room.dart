import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friends_chat/screens/login.dart';
import 'package:friends_chat/services/AuthService.dart';

import 'join_room.dart';

class ListRoomChat extends StatefulWidget {
  static const id = 'list_room_screen';
  final User user;

  const ListRoomChat(
      {Key? key,
      required this.user}
      ) : super(key: key);

  @override
  State<ListRoomChat> createState() => _ListRoomChatState();
}

class _ListRoomChatState extends State<ListRoomChat> {
  bool isLoading = false;

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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => JoinRoomScreen(),));
                    }, icon: Icon(Icons.add))
              ],
            ),
            body: isLoading ? CircularProgressIndicator() : Container(
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
                    IconButton(
                        splashColor: Colors.transparent,
                        onPressed: () async{
                          setState(() {
                            isLoading = true;
                          });
                          await AuthService.signOut();
                          setState(() {
                            isLoading = false;
                            if(!AuthService.check()){
                              Navigator.pop(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
                            }
                          });
                        }, icon: Icon(Icons.logout))
                  ]
                ),
            ),
        )
    );
  }
}
