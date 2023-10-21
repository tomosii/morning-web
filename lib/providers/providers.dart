import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/place.dart';
import '../verification/condition_status.dart';

final userEmailProvider = StateProvider<String?>((ref) => null);
final userNameProvider = StateProvider<String?>((ref) => null);

// final networkStatusProvider =
//     FutureProvider<NetworkStatus>((ref) => getNetworkStatus());

final checkInPlacesProvider = FutureProvider<List<CheckInPlace>>((ref) async {
  final db = FirebaseFirestore.instance;
  try {
    final snapshot = await db.collection("places").get();
    final places = snapshot.docs.map((e) {
      final data = e.data();
      return CheckInPlace.fromMap(data);
    }).toList();
    return places;
  } catch (e) {
    print(e);
    throw e;
  }
});
