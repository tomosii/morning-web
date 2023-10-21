import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/location.dart';
import 'condition_status.dart';

Future<LocationStatus> checkLocationStatus() async {
  final currentPosition = await getCurrentPosition();
  if (currentPosition.isMocked) {
    // モック位置情報の場合
    return LocationStatus.mocking;
  }

  final goalPositions = await getCheckInPositions();

  final distanceFromGoal = goalPositions.map((e) {
    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      e.latitude,
      e.longitude,
    );
    return distance;
  }).toList();

  final minDistance = distanceFromGoal.reduce((value, element) {
    return value < element ? value : element;
  });

  if (minDistance > 30) {
    return LocationStatus.outOfRange;
  } else {
    return LocationStatus.withinRange;
  }
}

// Future<NetworkStatus> checkNetworkStatus() async {

// }

Future<List<GeoPoint>> getCheckInPositions() async {
  final db = FirebaseFirestore.instance;
  final snapshot = await db.collection("places").get();
  final positions = snapshot.docs.map((e) {
    final data = e.data();
    final latlng = data["latlng"] as GeoPoint;
    return latlng;
  }).toList();
  return positions;
}
