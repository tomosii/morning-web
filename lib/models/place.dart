import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInPlace {
  final String id;
  final String name;
  final String ipAddress;
  final GeoPoint latLng;

  CheckInPlace({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.latLng,
  });

  factory CheckInPlace.fromMap(Map<String, dynamic> data) {
    print(data);
    final id = data["id"] as String;
    final name = data["name"] as String;
    final ipAddress = data["ipAddress"] as String;
    final latLng = data["latLng"] as GeoPoint;
    return CheckInPlace(
      id: id,
      name: name,
      ipAddress: ipAddress,
      latLng: latLng,
    );
  }
}
