import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friends_chat/services/AuthService.dart';

class GroupService {
  static String _collection = "groups";
  static final _firestore = FirebaseFirestore.instance;

  static Future createGroup({required String? groupId}) async {

    final QuerySnapshot result = await _firestore
        .collection(_collection)
        .where('groupId', isEqualTo: groupId)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isEmpty) {
      _firestore.collection(_collection).doc(groupId).set({
        'nameGroup': groupId,
        'groupId': groupId,
        'avatarGroup' : AuthService.user?.photoURL,
        'time' : DateTime.now()
      });
    }
  }

  static Stream<QuerySnapshot> groupStream() {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: AuthService.user?.uid)
        .orderBy('time', descending: true)
        .snapshots();
  }
}