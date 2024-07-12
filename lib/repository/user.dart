import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morning_web/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

final userRepositoryProvider = Provider((ref) {
  return UserRepository();
});

class UserRepository {
  final _ref = FirebaseFirestore.instance.collection("users");

  Future<User?> getUser(String email) async {
    final snapshot = await _ref.doc(email).get();
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    final user = User(
      id: data["id"],
      email: data["email"],
      nickname: data["nickname"],
    );

    print("Get user: $user");

    return user;
  }
}

// Future<bool> findUser(String email) async {
//   // 該当のメールアドレスを持つユーザーが存在するか確認

//   final db = FirebaseFirestore.instance;
//   final snapshot = await db.collection("users").doc(email).get();

//   if (snapshot.exists) {
//     print("User exists: $email");
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("email", email);
//     return true;
//   } else {
//     print("User not found: $email");
//     return false;
//   }
// }

// Future<void> fetchUserInfo(String email, Ref ref) async {
//   // emailを元にfirestoreからユーザーの名前を取得
//   final db = FirebaseFirestore.instance;
//   final snapshot = await db.collection("users").doc(email).get();
//   final data = snapshot.data();

//   if (data == null) {
//     print("User not found: $email");
//     return;
//   }

//   final userId = data["id"];
//   final userNickname = data["nickname"];

//   print("Fetch userinfo: email: $email, id: $userId, nickname: $userNickname");

//   ref.read(userEmailProvider.notifier).state = email;
//   ref.read(userIdProvider.notifier).state = userId;
//   ref.read(userNicknameProvider.notifier).state = userNickname;
// }
