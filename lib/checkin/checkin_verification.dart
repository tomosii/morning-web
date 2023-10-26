import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:morning_web/models/place.dart';
import 'package:morning_web/utils/ip_address.dart';

import '../utils/location.dart';
import 'condition_status.dart';

Future<NetworkStatus> checkNetworkStatus(
  Ref ref,
  List<CheckInPlace> checkInPlaces,
) async {
  final myIPAdress = await getIPAddress();

  print("現在のIPアドレス: $myIPAdress");

  // チェックイン場所のIPアドレスと比較
  for (final place in checkInPlaces) {
    for (final ip in place.ipAddresses) {
      if (myIPAdress.contains(ip)) {
        print("一致したIPアドレス: $ip");
        return NetworkStatus.valid;
      }
    }
  }

  print("一致するIPアドレス なし");
  return NetworkStatus.invalid;
}

Future<LocationStatus> checkLocationStatus(
  Ref ref,
  List<CheckInPlace> checkInplaces,
) async {
  Position currentPosition;
  try {
    currentPosition = await getCurrentPosition();
  } catch (e) {
    return LocationStatus.notAvailable;
  }

  if (currentPosition.isMocked) {
    // モック位置情報の場合
    return LocationStatus.mocking;
  }

  // 現在地から各場所までの距離を計算
  final distanceFromGoal = checkInplaces.map((place) {
    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      place.latLng.latitude,
      place.latLng.longitude,
    );
    return distance;
  }).toList();

  print("現在地からの距離: $distanceFromGoal");

  // 最短距離を取得
  final minDistance = distanceFromGoal.reduce(min);

  print("最短距離: $minDistance");

  if (minDistance > 30) {
    return LocationStatus.outOfRange;
  } else {
    return LocationStatus.withinRange;
  }
}
