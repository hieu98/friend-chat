import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friends_chat/services/auth_provider.dart';

class GroupProvider {
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
        'avatarGroup' : AuthProvider.user?.photoURL,
        'time' : DateTime.now()
      });
    }
  }

  static Stream<QuerySnapshot> groupStream({required String groupId}) {
    return _firestore
        .collection(_collection)
        .where('groupId', isEqualTo: groupId)
        .snapshots();
  }

  static Future renameGroup(
      {required String groupName, required String groupId}) {
    return _firestore
        .collection(_collection)
        .doc(groupId)
        .update({'nameGroup': groupName});
  }

  static Future checkGroupToDelete() async {
    final QuerySnapshot result = await _firestore
        .collection(_collection)
        .get();
    final List<DocumentSnapshot> documents = result.docs;

  }

  static Future deleteGroup({required String groupId}) {
    return _firestore.collection(_collection).doc(groupId).delete();
  }
}