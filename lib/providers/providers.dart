import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morning_web/pages/home_page.dart';
import 'package:morning_web/repository/firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/place.dart';
import '../verification/checkin_verification.dart';
import '../verification/condition_status.dart';

final userEmailProvider = StateProvider<String?>((ref) => null);
final userNameProvider = StateProvider<String?>((ref) => null);

final localEmailProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString("email");
  print("Email in local storage: $email");

  if (email != null) {
    fetchUserInfo(email, ref);

    // SharedPreferenceに上書き
    await prefs.setString("email", email);
  }

  return email;
});

final checkInPlacesProvider = FutureProvider<List<CheckInPlace>>((ref) async {
  final db = FirebaseFirestore.instance;
  final snapshot = await db.collection("place").get();
  final places = snapshot.docs.map((e) {
    return CheckInPlace.fromSnapshot(e);
  }).toList();
  print("チェックイン場所を取得: $places");
  return places;
});

final networkStatusProvider = FutureProvider<NetworkStatus>((ref) async {
  final checkInPlaces = await ref.watch(checkInPlacesProvider.future);
  return checkNetworkStatus(ref, checkInPlaces);
});

final locationStatusProvider = FutureProvider<LocationStatus>((ref) async {
  final checkInPlaces = await ref.watch(checkInPlacesProvider.future);
  return checkLocationStatus(ref, checkInPlaces);
});

final isCheckInAvailableProvider = FutureProvider<bool>((ref) async {
  final networkStatus = await ref.watch(networkStatusProvider.future);
  final locationStatus = await ref.watch(locationStatusProvider.future);

  if (networkStatus == NetworkStatus.valid &&
      locationStatus == LocationStatus.withinRange) {
    ref.read(buttonRippleOpacityProvider.notifier).state = 1.0;
    return true;
  } else {
    return false;
  }
});
