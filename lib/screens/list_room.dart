import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friends_chat/screens/login.dart';
import 'package:friends_chat/screens/room_chat.dart';
import 'package:friends_chat/screens/setting.dart';
import 'package:friends_chat/providers/auth_provider.dart';
import 'package:friends_chat/providers/group_provider.dart';
import 'package:friends_chat/providers/message_provider.dart';

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
  final _messageController = TextEditingController();

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
                    margin: EdgeInsets.only(top: 15),
                      child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: AuthProvider.nameStream(userId: widget.user.uid),
                                  builder: (context, snapshot) {
                                    if(!snapshot.hasData) {
                                      return Text("");
                                    }
                                    final docs = snapshot.data?.docs;
                                    return CachedNetworkImage(
                                        imageUrl: docs![0]['photoUrl'],
                                        placeholder: (context, url) => Center(heightFactor: 5, widthFactor: 5, child: CircularProgressIndicator(value: 0,)),
                                        errorWidget:(context, url, error) => Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 15),
                              child: TextButton(
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingScreen(isSettingUser: true, codeRoom: null),));
                                  },
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: AuthProvider.nameStream(userId: widget.user.uid),
                                    builder: (context, snapshot) {
                                      if(!snapshot.hasData) {
                                        return Text("");
                                      }
                                      final docs = snapshot.data?.docs;
                                      return Text(docs![0]['nickName'], style: TextStyle(fontSize: 17), overflow: TextOverflow.ellipsis,);
                                    },
                                  ),
                              ),
                            ),
                            IconButton(
                                splashColor: Colors.transparent,
                                onPressed: () async{
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await AuthProvider.signOut();
                                  setState(() {
                                    isLoading = false;
                                    if(!AuthProvider.check()){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(),));
                                    }
                                  });
                                }, icon: Icon(Icons.logout))
                          ]
                        ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: MessageProvider.groupIdByUserId(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData) {
                          return Center(
                            child: Text(""),
                          );
                        }
                        final docs = snapshot.data?.docs;
                        final size = snapshot.data?.size;
                        String groupId = "";
                        return ListView(
                          padding: EdgeInsets.all(8.0),
                          children: List.generate(
                              size!,
                              (index) {
                                groupId = ((index + 1) < size) ? docs![index + 1]['groupId'] : '';
                                return (groupId == docs![index]['groupId']) ? Container() : StreamBuilder<QuerySnapshot>(
                                  stream: GroupProvider.groupStream(groupId: docs[index]['groupId']),
                                  builder: (context, snapshot2) {
                                    if(!snapshot2.hasData) {
                                      return Center(
                                        child: Text(""),
                                      );
                                    }
                                    final docs2 = snapshot2.data?.docs;
                                    return GestureDetector(
                                      onTap: (){
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => RoomChat(
                                                  codeRoom: docs2![0]['groupId'],
                                                )
                                            )
                                        );
                                      },
                                      child: Card(
                                        shape: BeveledRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          side: BorderSide(color: Colors.black, width: 0.5)
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children:[
                                              Padding(
                                                padding: EdgeInsets.only(left: 10),
                                                child: CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Colors.white,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(25),
                                                    child: CachedNetworkImage(
                                                      imageUrl: docs2![0]['avatarGroup'],
                                                      placeholder: (context, url) => Center(heightFactor :5, widthFactor: 5, child: CircularProgressIndicator(value :0)),
                                                      errorWidget:(context, url, error) => Icon(Icons.error),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Padding(
                                                    padding: EdgeInsets.only(left: 10, right: 10),
                                                    child: Text(
                                                      docs2[0]['nameGroup'],
                                                      style: TextStyle(color: Colors.black, fontSize: 15,),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    )
                                                ),
                                              ),
                                            ]
                                          ),
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
