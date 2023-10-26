import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:morning_web/checkin/checkin_exception.dart';

class CheckInRepository {
  final String _url = "https://d964-157-82-14-84.ngrok-free.app/checkin";
  final String _apiKey = dotenv.env["MORNING_API_KEY"]!;

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
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
        "x-api-key": _apiKey,
      },
      body: body,
    );

    if (response.statusCode != 200) {
      print("チェックインに失敗: ${response.statusCode}, ${response.body}");
      final detail = jsonDecode(response.body)["detail"];
      throw CheckInException(detail);
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
  final String? placeId;
  final String? placeName;
  final double? timeDifferenceSeconds;

  CheckInResult({
    this.placeId,
    this.placeName,
    this.timeDifferenceSeconds,
  });
}
