import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friends_chat/screens/login.dart';
import 'package:friends_chat/screens/room_chat.dart';
import 'package:friends_chat/services/AuthService.dart';
import 'package:friends_chat/services/GroupService.dart';
import 'package:friends_chat/services/MessageService.dart';

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
            body: Column(
              children:[
                  Container(
                    height: 100,
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
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: MessageService.groupIdByUserId(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData) {
                          return Center(
                            child: Text(""),
                          );
                        }
                        final docs = snapshot.data?.docs;
                        final size = snapshot.data?.size;
                        String a = "";
                        return ListView(
                          padding: EdgeInsets.all(8.0),
                          children: List.generate(
                              size!,
                              (index) {
                                a = ((index + 1) < size) ? docs![index + 1]['groupId'] : '';
                                return (a == docs![index]['groupId']) ? Container() : StreamBuilder<QuerySnapshot>(
                                  stream: GroupService.groupStream(groupId: docs[index]['groupId']),
                                  builder: (context, snapshot2) {
                                    if(!snapshot2.hasData) {
                                      return Center(
                                        child: Text(""),
                                      );
                                    }
                                    final docs2 = snapshot2.data?.docs;
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0))
                                      ),
                                      color: Colors.blue,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: TextButton(
                                          child: Text(docs2![0]['nameGroup'], style: TextStyle(color: Colors.black, fontSize: 18)),
                                          onPressed: (){
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => RoomChat(
                                                      codeRoom: docs2[0]['groupId'],
                                                    )));
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                          ),
                        );
                      },
                  ),
                )
              ]
            ),
        )
    );
  }
}
