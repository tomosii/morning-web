import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morning_web/providers/providers.dart';

Future<void> fetchUserInfo(String email, Ref ref) async {
  // emailを元にfirestoreからユーザーの名前を取得
  final db = FirebaseFirestore.instance;
  final user = await db.collection("user").doc(email).get();
  final userName = user.data()!["name"];

  print("Fetch userinfo: email: $email, name: $userName");

  ref.read(userEmailProvider.notifier).state = email;
  ref.read(userNameProvider.notifier).state = userName;
}
