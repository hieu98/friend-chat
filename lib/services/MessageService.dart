import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  static String _collection = "message";
  static final _firestore = FirebaseFirestore.instance;

  static Future sendMessage({required String? message, required String senderId}) async {
    await _firestore.collection(_collection).add({
      'senderId' : senderId,
      'message' : message,
      'time' : DateTime.now()
    });
  }

  static Stream<QuerySnapshot> messageStream() {
    return _firestore
        .collection(_collection)
        .orderBy('time', descending: true)
        .snapshots();
  }
}