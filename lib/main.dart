import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:morning_web/constants/colors.dart';

import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MorningApp());
}

class MorningApp extends StatelessWidget {
  const MorningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale("ja", "JP"),
      title: "朝活",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "NotoSansJP",
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Image.asset(
                  'assets/images/morning-logo.png',
                  height: 45,
                ),
                const SizedBox(
                  height: 20,
                ),
                // Current date and time
                StreamBuilder<DateTime>(
                  stream: Stream.periodic(
                      const Duration(seconds: 1), (_) => DateTime.now()),
                  builder:
                      (BuildContext context, AsyncSnapshot<DateTime> snap) {
                    if (snap.hasData) {
                      final DateTime now = snap.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${now.year}年${now.month}月${now.day}日 (火)",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withOpacity(0.4),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
                            style: GoogleFonts.inter(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withOpacity(0.8),
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      );
                    } else if (snap.hasError) {
                      return Text("Error: ${snap.error}");
                    } else {
                      return Container();
                    }
                  },
                ),
                const SizedBox(
                  height: 40,
                ),

                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 35,
                          offset: const Offset(0, 0),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 17,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.wifi_rounded,
                              color: morningBlue,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                "指定のネットワークに接続されています",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(0.65),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.gps_fixed_rounded,
                              color: morningBlue,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                "チェックインエリア圏内です",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(0.65),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 100,
                ),

                // circle button
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      shadows: [
                        BoxShadow(
                          color: morningBlue.withOpacity(0.25),
                          blurRadius: 45,
                          offset: const Offset(0, 0),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.brightness_7,
                        color: morningBlue,
                        size: 35,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 70,
                ),

                FutureBuilder<Position>(
                  future: _determinePosition(),
                  builder:
                      (BuildContext context, AsyncSnapshot<Position> snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                          'Location: ${snapshot.data!.latitude}, ${snapshot.data!.longitude}');
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const Text('Loading...');
                    }
                  },
                ),
                FutureBuilder<String>(
                  future: _getIPAddress(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Text('IP Address: ${snapshot.data}');
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const Text('Loading...');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

Future<String> _getIPAddress() async {
  final response =
      await http.get(Uri.parse('https://api.ipify.org?format=json'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body)['ip'];
  } else {
    throw Exception('Failed to get IP address');
  }
}
