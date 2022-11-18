import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friends_chat/services/AuthService.dart';

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

  static Stream<QuerySnapshot> groupIdByUserId() {
    return _firestore
        .collection(_collection)
        .where('senderId', isEqualTo: AuthService.user?.uid)
        .orderBy('groupId', descending: true)
        .snapshots();
  }
}