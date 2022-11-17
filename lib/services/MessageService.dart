import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  static String _collection = "message";
  static final _firestore = FirebaseFirestore.instance;

  static Future sendMessage({required String? message, required String senderId, required String groupId}) async {
    await _firestore.collection(_collection).doc(message).set({
      'senderId' : senderId,
      'groupId' : groupId,
      'message' : message,
      'time' : DateTime.now()
    });
  }

  static Stream<QuerySnapshot> messageStream({required String groupId}) {
    return _firestore
        .collection(_collection)
        .where('groupId', isEqualTo: groupId)
        .orderBy('time', descending: true)
        .snapshots();
  }
}