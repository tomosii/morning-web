import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> getIPAddress() async {
  final response =
      await http.get(Uri.parse('https://api.ipify.org?format=json'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['ip'];
  } else {
    throw Exception('Failed to get IP address');
  }
}
