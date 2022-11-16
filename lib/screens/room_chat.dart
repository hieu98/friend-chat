import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friends_chat/databases/message_dao.dart';
import 'package:friends_chat/models/message.dart';
import 'package:friends_chat/services/MessageService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';

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

  final _messageController = TextEditingController();
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

    await MessageService.sendMessage(message: message, senderId: _user.uid);
  }

  Future deleteMessage() async{
    await FirebaseFirestore.instance
        .collection('message')
        .doc('message')
        .delete();
  }

  Widget _buildComposer() {
    return Padding(
      padding: EdgeInsets.all(3.0),
      child: Row(
        children: [
          IconButton(
            splashColor: Colors.transparent,
              onPressed: () async {
                //file = await picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  deleteMessage();
                });
              },
              icon: Icon(Icons.image)
          ),
          Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 8, bottom: 5),
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
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
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.focusedChild?.unfocus();
            }
            print(widget.codeRoom);
          },
          child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  splashColor: Colors.transparent,
                    onPressed: () async{
                      await Share.share(widget.codeRoom);
                    },
                    icon: Icon(Icons.share)
                )
              ],
      ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: MessageService.messageStream(),
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
                                  Text(_user.displayName ?? 'No name'),
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
                                      child:Text(
                                              docs[index]['message'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0
                                              ),
                                            ),
                                    ),
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
