import 'package:firebase_database/firebase_database.dart';
import 'package:friends_chat/models/message.dart';

class MessageDao {
  final DatabaseReference _messageRef =
      FirebaseDatabase.instance.ref().child('message');

  void saveMessage(Message message) {
    _messageRef.push().set(message.toJson());
  }

  Query getMessageQuery() {
    return _messageRef;
  }
}