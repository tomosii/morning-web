import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:morning_web/checkin/checkin_exception.dart';

class CheckInRepository {
  final String _baseUrl = "https://slack-morning-bot.vercel.app";
  // final String _baseUrl = "http://127.0.0.1:8000";

  final String _apiKey = dotenv.env["MORNING_API_KEY"]!;

  Future<CheckInResult> post(
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
      Uri.parse("$_baseUrl/checkin"),
      headers: {
        "Content-Type": "application/json",
        "x-api-key": _apiKey,
      },
      body: body,
    );

    if (response.statusCode != 200) {
      print("チェックインに失敗: ${response.statusCode}, ${response.body}");
      final detail = jsonDecode(response.body)["detail"];
      switch (detail) {
        case "User not found.":
          throw UserNotFoundException();
        case "User doesn't have a commitment today.":
          throw NotCommittedException();
        case "Already checked in today.":
          throw AlreadyCheckedInException();
        case "IP address not matched with any place.":
          throw InvalidIpAddressException();
        case "Out of range of the check-in area.":
          throw InvalidPlaceException();
        default:
          throw CheckInException(detail);
      }
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

  @override
  String toString() {
    return "CheckInResult(placeId: $placeId, placeName: $placeName, timeDifferenceSeconds: $timeDifferenceSeconds)";
  }
}
