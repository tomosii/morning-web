import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morning_web/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> fetchUserInfo(String email, WidgetRef ref) async {
  // emailを元にfirestoreからユーザーの名前を取得
  final db = FirebaseFirestore.instance;
  final user = await db.collection("user").doc(email).get();
  final userName = user.data()!["name"];

  print("email: $email, name: $userName");

  ref.read(userEmailProvider.notifier).state = email;
  ref.read(userNameProvider.notifier).state = userName;

  // SharedPreferenceに上書き
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("email", email);
}
