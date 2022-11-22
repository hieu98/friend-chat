import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:friends_chat/databases/message_dao.dart';
import 'package:friends_chat/models/message.dart';
import 'package:friends_chat/screens/list_room.dart';
import 'package:friends_chat/providers/auth_provider.dart';
import 'package:friends_chat/providers/group_provider.dart';
import 'package:friends_chat/providers/message_provider.dart';
import 'package:friends_chat/providers/setting_provider.dart';
import 'package:friends_chat/screens/setting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

import '../utils/utils.dart';
import 'full_photo.dart';

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
  bool isTyping = false;

  Future _sendMessage() async {
    final message = _messageController.text.trim();
    final msg = Message(_messageController.text, DateTime.now());
    setState(() {
      messageDao.saveMessage(msg);
      _messageController.clear();
      _isComposing = false;
    });

    await MessageProvider.sendMessage(message: message, senderId: _user.uid, groupId: widget.codeRoom, typeMessage: 'text');
  }

  Future uploadFile(XFile file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = SettingProvider().uploadFile(file, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      MessageProvider.sendMessage(message: imageUrl, senderId: _user.uid, groupId: widget.codeRoom, typeMessage: 'image');
    } on FirebaseException catch (e) {
      setState(() {
        //isLoading = false;
      });
    }
  }

  Widget _buildComposer() {
    return Padding(
      padding: EdgeInsets.all(3.0),
      child: Row(
        children: [
          isTyping
              ?  IconButton(
                splashColor: Colors.transparent,
                onPressed: (){
                  setState(() {
                    isTyping = false;
                  });
                },
                icon: Icon(Icons.navigate_next))
              :IconButton(
                splashColor: Colors.transparent,
                onPressed: () async {
                  var a = await Utils.askPermission();
                  if(a){
                    // file = await picker.pickImage(source: ImageSource.gallery);
                    // uploadFile(file!);
                  }
                },
                icon: Icon(Icons.camera_alt)
          ),
          isTyping ? Container() : IconButton(
            splashColor: Colors.transparent,
              onPressed: () async {
              var a = await Utils.askPermission();
                if(a){
                  file = await picker.pickImage(source: ImageSource.gallery);
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
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    fillColor: Colors.grey,
                    isCollapsed: true,
                    hintText: "Nhập tin nhắn ...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    contentPadding: EdgeInsets.all(10.0),
                    suffixIcon: IconButton(
                        onPressed :(){

                        },
                        icon : Icon(Icons.tag_faces)
                    ),
                  ),
                  onChanged: (value){
                    setState(() {
                      _isComposing = value.isNotEmpty;
                    });
                  },
                  onTap: (){
                    setState(() {
                      isTyping = true;
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
                stream: GroupProvider.groupStream(groupId: widget.codeRoom),
                builder: (context, snapshot) {
                  if(!snapshot.hasData) {
                    return Text("");
                  }
                  final docs = snapshot.data?.docs;
                  return Text(docs![0]['nameGroup']);
                },
              ),
              leading: BackButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ListRoomChat(user: AuthProvider.user!))),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingScreen(isSettingUser: false, codeRoom: widget.codeRoom)));
                    },
                    icon: Icon(Icons.settings)
                ),
              ],
      ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: MessageProvider.messageStream(groupId: widget.codeRoom,),
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
                                  Container(
                                    margin :EdgeInsets.only(left: 35, right: 35),
                                    child: StreamBuilder<QuerySnapshot>(
                                        stream: AuthProvider.nameStream(userId: docs[index]['senderId']),
                                        builder: (context, snapshot) {
                                          if(!snapshot.hasData) {
                                            return Text("");
                                          }
                                          final docs = snapshot.data?.docs;
                                          return Text(docs![0]['nickName']);
                                        },
                                    ),
                                  ),
                                    Row(
                                        mainAxisAlignment: docs[index]['senderId'] == _user.uid
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children:[
                                          Padding(
                                            padding:EdgeInsets.only(bottom: 5),
                                            child: StreamBuilder<QuerySnapshot>(
                                              stream: AuthProvider.nameStream(userId: docs[index]['senderId']),
                                              builder: (context, snapshot) {
                                                if(!snapshot.hasData) {
                                                  return Text("");
                                                }
                                                final docs1 = snapshot.data?.docs;
                                                return docs[index]['senderId'] != _user.uid ? Material(
                                                  child: CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor: Colors.white,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(15),
                                                      child: CachedNetworkImage(
                                                        width: 35,
                                                        height: 35,
                                                        imageUrl: docs1![0]['photoUrl'],
                                                        placeholder: (context, url) => CircularProgressIndicator(),
                                                        errorWidget:(context, url, error) => Icon(Icons.error),
                                                      ),
                                                    ),
                                                  ),
                                                ): Container();
                                              },
                                            ),
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
                                                stream: MessageProvider.messageStream(groupId: widget.codeRoom),
                                                builder: (context, snapshot) {
                                                  if(!snapshot.hasData) {
                                                    return Text("");
                                                  }
                                                  final docs1 = snapshot.data?.docs;
                                                  return docs1![index]['typeMessage'] == 'image' ? Material(
                                                    child: GestureDetector(
                                                      onTap: (){
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => FullPhotoScreen(url: docs1[index]['message']),));
                                                      },
                                                      child: CachedNetworkImage(
                                                        imageUrl: docs1[index]['message'],
                                                        width: 100,
                                                        height: 100,
                                                        placeholder: (context, url) => CircularProgressIndicator(),
                                                        errorWidget:(context, url, error) => Icon(Icons.error),
                                                      ),
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
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 5),
                                            child: StreamBuilder<QuerySnapshot>(
                                              stream: AuthProvider.nameStream(userId: docs[index]['senderId']),
                                              builder: (context, snapshot) {
                                                if(!snapshot.hasData) {
                                                  return Text("");
                                                }
                                                final docs1 = snapshot.data?.docs;
                                                return docs[index]['senderId'] == _user.uid ? Material(
                                                  child: CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor: Colors.white,
                                                    child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(15),
                                                        child: CachedNetworkImage(
                                                          width: 35,
                                                          height: 35,
                                                          imageUrl: docs1![0]['photoUrl'],
                                                          placeholder: (context, url) => CircularProgressIndicator(),
                                                          errorWidget:(context, url, error) => Icon(Icons.error),
                                                        ),
                                                    ),
                                                  )
                                                ): Container();
                                              },
                                            ),
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
