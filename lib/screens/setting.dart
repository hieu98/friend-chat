import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:friends_chat/providers/group_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/auth_provider.dart';
import '../providers/setting_provider.dart';
import '../utils/utils.dart';

class SettingScreen extends StatefulWidget {
  final bool isSettingUser;
  final String? codeRoom;

  const SettingScreen({Key? key, required this.isSettingUser, required this.codeRoom})
      : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  final _textFieldController = TextEditingController();
  ImagePicker picker = ImagePicker();
  XFile? file;
  late String imageUrl;
  bool isLoading = false;

  Future uploadFile(XFile file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = SettingProvider().uploadFile(file, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      widget.isSettingUser ? AuthProvider.changeAvatarUser(url: imageUrl) : GroupProvider.changeAvatarGroup(url: imageUrl, groupId: widget.codeRoom!);
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.isSettingUser ? AuthProvider.nameStream(userId: AuthProvider.user?.uid) : GroupProvider.groupStream(groupId : widget.codeRoom!),
        builder: (context, snapshot) {
          if(!snapshot.hasData) {
            return Text("");
          }
          final docs = snapshot.data?.docs;
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child:
                GestureDetector(
                  onTap: () async{
                    var checkPermission = await Utils.askPermission([Permission.storage, Permission.mediaLibrary]);
                    if(checkPermission){
                      file = await picker.pickImage(source: ImageSource.gallery);
                      uploadFile(file!);
                    }
                  },
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: CachedNetworkImage(
                        imageUrl: widget.isSettingUser ? docs![0]['photoUrl'] : docs![0]['avatarGroup'],
                        placeholder: (context, url) => Center(heightFactor: 20, widthFactor: 20, child: CircularProgressIndicator()),
                        errorWidget:(context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(padding: EdgeInsets.only(right: 7, left: 17, top: 10, bottom: 10),child: Text('Name:')),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                      child: TextField(
                        controller: _textFieldController,
                        autofocus: false,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                            hintText: widget.isSettingUser ? docs[0]['nickName'] : docs[0]['nameGroup'],
                            fillColor: Colors.grey,
                            isCollapsed: true,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(10.0)),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: ElevatedButton(
                    onPressed: () {
                      if(_textFieldController.text.isNotEmpty){
                        widget.isSettingUser
                            ? AuthProvider.renameUser(name: _textFieldController.text)
                            : GroupProvider.renameGroup(groupName: _textFieldController.text, groupId: widget.codeRoom!);
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text('Save')),
              )
            ],
          );
        },
      ),
    );
  }
}
