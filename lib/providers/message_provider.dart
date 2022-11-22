import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friends_chat/providers/auth_provider.dart';

class MessageProvider {
  static String _collection = "messages";
  static final _firestore = FirebaseFirestore.instance;

  static Future sendMessage({required String? message, required String senderId, required String groupId, required String typeMessage}) async {
    await _firestore.collection(_collection).doc(DateTime.now().toString()).set({
      'senderId' : senderId,
      'groupId' : groupId,
      'message' : message,
      'typeMessage' : typeMessage,
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
        .where('senderId', isEqualTo: AuthProvider.user?.uid)
        .orderBy('groupId', descending: true)
        .snapshots();
  }
}