import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morning_web/repository/checkin.dart';
import 'package:morning_web/repository/firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/place.dart';
import '../checkin/checkin_verification.dart';
import '../checkin/checkin_status.dart';

final userEmailProvider = StateProvider<String?>((ref) => null);
final userNicknameProvider = StateProvider<String?>((ref) => null);

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
  try {
    final snapshot = await db.collection("places").get();
    final places = snapshot.docs.map((e) {
      return CheckInPlace.fromSnapshot(e);
    }).toList();
    print("チェックイン場所を取得: $places");
    return places;
  } catch (e) {
    print("チェックイン場所の取得に失敗: $e");
    rethrow;
  }
});

final networkStatusProvider = FutureProvider<NetworkStatus>((ref) async {
  final checkInPlaces = await ref.watch(checkInPlacesProvider.future);
  NetworkStatus status = await checkNetworkStatus(ref, checkInPlaces);
  return status;
});

final locationStatusProvider = FutureProvider<LocationStatus>((ref) async {
  final checkInPlaces = await ref.watch(checkInPlacesProvider.future);
  return checkLocationStatus(ref, checkInPlaces);
});

final isCheckInAvailableProvider = FutureProvider<bool>((ref) async {
  final networkStatus = await ref.watch(networkStatusProvider.future);
  final locationStatus = await ref.watch(locationStatusProvider.future);

  return true;

  if (networkStatus == NetworkStatus.valid &&
      locationStatus == LocationStatus.withinRange) {
    ref.read(checkInButtonRippleOpacityProvider.notifier).state = 1.0;
    return true;
  } else {
    ref.read(checkInButtonRippleOpacityProvider.notifier).state = 0.0;
    return false;
  }
});

final checkInButtonRippleOpacityProvider = StateProvider<double>((ref) {
  return 0.0;
});

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  return CheckInRepository();
});

final checkInResultProvider = StateProvider<CheckInResult>((ref) {
  return CheckInResult();
});

final networkDestinationProvider = StateProvider<String>((ref) {
  return "";
});

final locationDistanceProvider = StateProvider<double>((ref) {
  return 0.0;
});

final locationNameProvider = StateProvider<String>((ref) {
  return "";
});

final checkInProcessStatusProvider = StateProvider<CheckInProcessStatus>((ref) {
  return CheckInProcessStatus.notStarted;
});
