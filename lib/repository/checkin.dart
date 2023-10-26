import 'dart:convert';

import 'package:http/http.dart' as http;

class CheckInRepository {
  final Uri _url =
      Uri.parse("https://d964-157-82-14-84.ngrok-free.app/checkin");

  Future<CheckInResult> checkIn(
    String email,
    String ipAddress,
    double latitude,
    double longitude,
  ) async {
    final body = jsonEncode({
      "email": email,
      "ip_address": ipAddress,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
    });
    final response = await http.post(
      _url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode != 200) {
      print("チェックインに失敗しました: ${response.body}");
      final detail = jsonDecode(response.body)["detail"];
      throw Exception("チェックインに失敗しました: $detail");
    }

    final data = jsonDecode(response.body);
    return CheckInResult(
      placeId: data["place_id"],
      placeName: data["place_name"],
      timeDifferenceSeconds: data["time_difference_seconds"],
    );
  }
}

class CheckInResult {
  final String placeId;
  final String placeName;
  final double timeDifferenceSeconds;

  CheckInResult({
    required this.placeId,
    required this.placeName,
    required this.timeDifferenceSeconds,
  });
}
