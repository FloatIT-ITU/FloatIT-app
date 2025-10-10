import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static Future<bool> isAdmin(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final isAdmin = doc.data()?['admin'] == true;
    // production: no debug prints
    return isAdmin;
  }

  static Future<void> updateAdminStatus(String userId, bool isAdmin) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'admin': isAdmin,
    }, SetOptions(merge: true));
  }

  static Future<void> updateOccupation(String userId, String occupation) async {
    await FirebaseFirestore.instance.collection('public_users').doc(userId).set({
      'occupation': occupation,
    }, SetOptions(merge: true));
  }

  static Future<void> updateDisplayName(String userId, String displayName) async {
    await FirebaseFirestore.instance.collection('public_users').doc(userId).set({
      'displayName': displayName,
    }, SetOptions(merge: true));
  }
}
