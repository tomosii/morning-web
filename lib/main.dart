import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'pages/email_page.dart';
import 'pages/home_page.dart';
import 'pages/result_page.dart';
import 'repository/firestore.dart';
import 'utils/screen_size.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  usePathUrlStrategy();
  runApp(
    ProviderScope(
      child: MaterialApp(
        locale: const Locale("ja", "JP"),
        title: "朝活",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "NotoSansJP",
        ),
        home: const MorningApp(),
        routes: {
          "/result": (_) => const CheckInResultPage(),
        },
      ),
    ),
  );
}

class MorningApp extends ConsumerStatefulWidget {
  const MorningApp({super.key});

  @override
  ConsumerState<MorningApp> createState() => _MorningAppState();
}

class _MorningAppState extends ConsumerState<MorningApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScreenSize(context);
  }

  Future<String?> _getLocalEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString("email");
    if (email != null) {
      fetchUserInfo(email, ref);
    }
    return email;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getLocalEmail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final email = snapshot.data;
          if (email == null) {
            return const EmailPage();
          } else {
            return const HomePage();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
