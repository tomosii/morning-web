import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morning_web/providers/providers.dart';

Future<void> fetchUserInfo(String email, Ref ref) async {
  // emailを元にfirestoreからユーザーの名前を取得
  final db = FirebaseFirestore.instance;
  final user = await db.collection("users").doc(email).get();
  final userNickname = user.data()!["nickname"];

  print("Fetch userinfo: email: $email, name: $userNickname");

  ref.read(userEmailProvider.notifier).state = email;
  ref.read(userNicknameProvider.notifier).state = userNickname;
}
