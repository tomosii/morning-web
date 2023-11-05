import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:morning_web/models/place.dart';
import 'package:morning_web/providers/providers.dart';
import 'package:morning_web/utils/ip_address.dart';

import '../components/error_dialog.dart';
import '../repository/checkin.dart';
import '../utils/location.dart';
import 'checkin_status.dart';

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
        print("一致したIPアドレス: $ip (${place.name})");
        final currentPlace = place;
        ref.read(networkDestinationProvider.notifier).state = currentPlace.name;
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
  final minDistancePlace = checkInplaces[distanceFromGoal.indexOf(minDistance)];

  print("最短距離: $minDistance (${minDistancePlace.name})");

  ref.read(locationDistanceProvider.notifier).state = minDistance;
  ref.read(locationNameProvider.notifier).state = minDistancePlace.name;

  if (minDistance > 30) {
    return LocationStatus.outOfRange;
  } else {
    return LocationStatus.withinRange;
  }
}

Future<void> checkIn(BuildContext context, WidgetRef ref) async {
  print("チェックイン処理を開始");
  final email = ref.read(userEmailProvider)!;

  ref.read(checkInProcessStatusProvider.notifier).state =
      CheckInProcessStatus.fetchingNetwork;
  print("IPアドレスを取得中...");
  final ipAddress = await getIPAddress();

  await Future.delayed(Duration(milliseconds: 1200));

  ref.read(checkInProcessStatusProvider.notifier).state =
      CheckInProcessStatus.fetchingLocation;
  print("位置情報を取得中...");
  final currentPosition = await getCurrentPosition();

  await Future.delayed(Duration(milliseconds: 1200));

  ref.read(checkInProcessStatusProvider.notifier).state =
      CheckInProcessStatus.connectingToServer;
  print("サーバーと通信中...");

  await Future.delayed(Duration(milliseconds: 1200));

  try {
    final result = await CheckInRepository().post(
      email,
      ipAddress,
      currentPosition.latitude,
      currentPosition.longitude,
    );
    print("Check-in result: $result");

    ref.read(checkInResultProvider.notifier).state = result;
    ref.read(checkInProcessStatusProvider.notifier).state =
        CheckInProcessStatus.done;

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/result",
      (_) => false,
    );
  } on Exception catch (error) {
    // 場所を再取得することで、ステータスを再評価 -> 画面更新
    ref.invalidate(checkInPlacesProvider);

    await showDialog(
      context: context,
      builder: (_) {
        return MorningErrorDialog(
          title: "チェックインに失敗しました",
          message: error.toString(),
        );
      },
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/",
      (_) => false,
    );
  }
}
