import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:friends_chat/databases/message_dao.dart';
import 'package:friends_chat/models/message.dart';
import 'package:friends_chat/screens/list_room.dart';
import 'package:friends_chat/services/AuthService.dart';
import 'package:friends_chat/services/GroupService.dart';
import 'package:friends_chat/services/MessageService.dart';
import 'package:friends_chat/services/SettingService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

import '../utils/utils.dart';

class RoomChat extends StatefulWidget {
  static const id = 'room_chat_screen';
  final String codeRoom;

  const RoomChat(
      {Key? key,
      required this.codeRoom})
      : super(key: key);

  @override
  State<RoomChat> createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  ImagePicker picker = ImagePicker();
  XFile? file;
  late String imageUrl;

  final _messageController = TextEditingController();
  final _messageControllerSetting = TextEditingController();
  final _messageFocusNode = FocusNode();

  final messageDao = MessageDao();

  bool _isComposing = false;
  late User _user;

  Future _sendMessage() async {
    final message = _messageController.text.trim();
    final msg = Message(_messageController.text, DateTime.now());
    setState(() {
      messageDao.saveMessage(msg);
      _messageController.clear();
      _isComposing = false;
    });

    await MessageService.sendMessage(message: message, senderId: _user.uid, groupId: widget.codeRoom, typeMessage: 'text');
  }

  Future<bool> askPermission() async{
    PermissionStatus status = await Permission.storage.request();
    if(status.isDenied == true)
    {
      //openAppSettings();
      return false;
    }
    else
    {
      return true;
    }
  }

  Future uploadFile(XFile file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = SettingService().uploadFile(file, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      MessageService.sendMessage(message: imageUrl, senderId: _user.uid, groupId: widget.codeRoom, typeMessage: 'image');
    } on FirebaseException catch (e) {
      setState(() {
        //isLoading = false;
      });
      //Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  Widget _buildComposer() {
    return Padding(
      padding: EdgeInsets.all(3.0),
      child: Row(
        children: [
          IconButton(
            splashColor: Colors.transparent,
              onPressed: () async {
              var a = await askPermission();
                if(a){
                  file = await picker.pickImage(source: ImageSource.gallery);
                  print('!123 ${file?.path}');
                  uploadFile(file!);
                }
              },
              icon: Icon(Icons.image)
          ),
          Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 8, bottom: 5),
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  autofocus: false,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    fillColor: Colors.grey,
                    isCollapsed: true,
                    hintText: "Nhập tin nhắn ...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    contentPadding: EdgeInsets.all(10.0)
                  ),
                  onChanged: (value){
                    setState(() {
                      _isComposing = value.isNotEmpty;
                    });
                  },
                ),
              )
          ),
          IconButton(
              onPressed: _isComposing && _user != null ? _sendMessage : null ,
              icon: Icon(Icons.send),
              color: Colors.blue,
          )
        ],
      ),
    );
  }

  Future _getUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    _user = auth.currentUser!;
    setState(() {});
  }

  @override
  void initState() {
    _getUser();
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
            appBar: AppBar(
              title: StreamBuilder<QuerySnapshot>(
                stream: GroupService.groupStream(groupId: widget.codeRoom),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) {
                    return Text("");
                  }
                  final docs = snapshot.data?.docs;
                  return Text(docs![0]['nameGroup']);
                },
              ),
              leading: BackButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ListRoomChat(user: AuthService.user!))),
              ),
              actions: [
                IconButton(
                  splashColor: Colors.transparent,
                    onPressed: () async{
                      await Share.share(widget.codeRoom);
                    },
                    icon: Icon(Icons.share)
                ),
                IconButton(
                    splashColor: Colors.transparent,
                    onPressed: (){
                      showDialog(context: context, builder: (context) {
                        return Center(
                          child: Card(
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                            child: Container(
                              child: Column(
                                children: [
                                  Container(
                                    child: Text('Change Name', textAlign: TextAlign.center,),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(20),
                                    child: TextField(
                                      controller: _messageControllerSetting,
                                    ),
                                  ),
                                  ElevatedButton(onPressed: (){
                                    GroupService.renameGroup(groupName: _messageControllerSetting.text, groupId: widget.codeRoom);
                                    Navigator.of(context).pop();
                                    }, child: Text('Ok'))
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    },
                    icon: Icon(Icons.settings)
                ),
              ],
      ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: MessageService.messageStream(groupId: widget.codeRoom,),
                    builder: (context, snapshot) {
                      if(!snapshot.hasData) {
                        return Center(
                          child: Text("No message here", style: TextStyle(fontSize: 20, color: Colors.black54),),
                        );
                      }
                      final docs = snapshot.data?.docs;
                      final size = snapshot.data?.size;
                      return ListView(
                        padding: EdgeInsets.all(8.0),
                        reverse: true,
                        children: List.generate(
                            size!,
                            (index) {
                              return Column(
                                crossAxisAlignment: docs![index]['senderId'] == _user.uid
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                                children: [
                                  StreamBuilder<QuerySnapshot>(
                                      stream: AuthService.nameStream(userId: docs[index]['senderId']),
                                      builder: (context, snapshot) {
                                        if(!snapshot.hasData) {
                                          return Text("");
                                        }
                                        final docs = snapshot.data?.docs;
                                        return Text(docs![0]['nickName']);
                                      },
                                  ),
                                    Row(
                                        mainAxisAlignment: docs[index]['senderId'] == _user.uid
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children:[
                                          StreamBuilder<QuerySnapshot>(
                                            stream: AuthService.nameStream(userId: docs[index]['senderId']),
                                            builder: (context, snapshot) {
                                              if(!snapshot.hasData) {
                                                return Text("");
                                              }
                                              final docs1 = snapshot.data?.docs;
                                              return docs[index]['senderId'] != _user.uid ? Material(
                                                child: Image.network(
                                                  docs1![0]['photoUrl'],
                                                  width: 35,
                                                  height: 35,
                                                  fit: BoxFit.cover,
                                                ),
                                              ): Container();
                                            },
                                          ),

                                          Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8.0),
                                                topRight: Radius.circular(8.0),
                                                bottomLeft: Radius.circular(
                                                  docs[index]['senderId'] == _user.uid
                                                      ? 8.0
                                                      : 0.0),
                                                bottomRight: Radius.circular(
                                                  docs[index]['senderId'] == _user.uid
                                                      ? 0.0
                                                      : 8.0),
                                                )
                                              ),
                                            color: docs[index]['senderId'] == _user.uid
                                                  ? Colors.blue
                                                  : Colors.blueGrey,
                                            elevation: 0.0,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child:
                                              StreamBuilder<QuerySnapshot>(
                                                stream: MessageService.messageStream(groupId: widget.codeRoom),
                                                builder: (context, snapshot) {
                                                  if(!snapshot.hasData) {
                                                    return Text("");
                                                  }
                                                  final docs1 = snapshot.data?.docs;
                                                  return docs1![index]['typeMessage'] == 'image' ? Material(
                                                    child: Image.network(
                                                      docs1[index]['message'],
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ): Text(
                                                    docs[index]['message'],
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18.0
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          StreamBuilder<QuerySnapshot>(
                                            stream: AuthService.nameStream(userId: docs[index]['senderId']),
                                            builder: (context, snapshot) {
                                              if(!snapshot.hasData) {
                                                return Text("");
                                              }
                                              final docs1 = snapshot.data?.docs;
                                              return docs[index]['senderId'] == _user.uid ? Material(
                                                child: Image.network(
                                                  docs1![0]['photoUrl'],
                                                  width: 35,
                                                  height: 35,
                                                  fit: BoxFit.cover,
                                                ),
                                              ): Container();
                                            },
                                          ),
                                        ]
                                    ),
                                  SizedBox(height: 4.0,)
                                ],
                              );
                            }
                        ),
                      );
                    },
                  ),
                ),
                _buildComposer()
              ],
            )
          ),
        )
    );
  }
}
