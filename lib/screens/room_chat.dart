import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class RoomChat extends StatefulWidget {
  const RoomChat({Key? key}) : super(key: key);

  @override
  State<RoomChat> createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  var textChat = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () async{
                    await Share.share('123');
                  },
                  icon: Icon(Icons.send)
              )
            ],
      ),
          body: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.blue,
                  ),
                  Container(
                    alignment: FractionalOffset.bottomCenter,
                    decoration: BoxDecoration(border: Border.all()),
                    child: TextField(
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      onChanged: (text) {
                        setState(() {
                          textChat = text;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}
