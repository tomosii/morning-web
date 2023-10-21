import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morning_web/components/error_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/text_form.dart';
import '../components/primary_button.dart';
import '../providers/providers.dart';
import 'home_page.dart';

class EmailPage extends ConsumerStatefulWidget {
  const EmailPage({Key? key}) : super(key: key);

  @override
  ConsumerState<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends ConsumerState<EmailPage> {
  final _emailTextController = TextEditingController(text: "");

  bool _loading = false;

  @override
  void dispose() {
    _emailTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _logo(),
                  const SizedBox(
                    height: 80,
                  ),
                  _forms(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Image.asset(
      "assets/images/morning-logo.png",
      height: 50,
    );
  }

  Widget _forms(BuildContext context) {
    return AutofillGroup(
      child: Column(
        children: [
          SimpleTextForm(
            hintText: "Weblabドメインのメールアドレス",
            controller: _emailTextController,
            node: FocusScope.of(context),
            autofillHint: AutofillHints.email,
            done: true,
          ),
          const SizedBox(
            height: 100,
          ),
          PrimaryButton(
            icon: Icons.arrow_forward_rounded,
            width: 120,
            onTap: () {
              FocusScope.of(context).unfocus();
              _validateEmail();
            },
            loading: _loading,
          ),
        ],
      ),
    );
  }

  void _validateEmail() async {
    // フォームから文字列を取得（スペースを除く）
    final email = _emailTextController.text.trim();
    if (email.isEmpty) {
      return;
    }

    setState(() {
      _loading = true;
    });

    final userExists = await findUser(email);

    if (!userExists) {
      // ユーザーが存在しない場合
      setState(() {
        _loading = false;
      });
      showDialog(
        context: context,
        builder: (_) {
          return MorningErrorDialog(
            title: "未登録のメールアドレスです",
            message: "メールアドレスが間違っているか、登録されていません。\n未登録の場合は管理者に連絡してください。",
          );
        },
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  Future<bool> findUser(String email) async {
    final db = FirebaseFirestore.instance;

    // 該当のメールアドレスを持つユーザーが存在するか確認
    final snapshot = await db.collection("user").doc(email).get();

    if (snapshot.exists) {
      final data = snapshot.data();
      ref.read(userEmailProvider.notifier).state = email;
      ref.read(userNameProvider.notifier).state = data?["name"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("email", email);
      await prefs.setString("name", data?["name"]);
      return true;
    } else {
      return false;
    }
  }
}
