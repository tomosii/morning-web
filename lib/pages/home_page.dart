import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morning_web/providers/providers.dart';

import '../../constants/colors.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  double _titleOpacity = 0;
  double _formOpacity = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                height: 20,
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
                builder: (BuildContext context, AsyncSnapshot<DateTime> snap) {
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
                            color: Colors.black.withOpacity(0.7),
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
                height: 60,
              ),

              // circle button
              Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.all(0),
                    ),
                    onPressed: () {},
                    child: Icon(
                      Icons.brightness_7,
                      color: morningBlue,
                      size: 35,
                    ),
                  ),
                ),
              ),

              ref.watch(checkInPlacesProvider).when(
                data: (places) {
                  return Column(
                    children: places.map((e) {
                      return Text(e.name);
                    }).toList(),
                  );
                },
                loading: () {
                  return const Text("Loading...");
                },
                error: (e, s) {
                  return Text("Error: $e");
                },
              ),

              const SizedBox(
                height: 70,
              ),

              // FutureBuilder<Position>(
              //   future: _determinePosition(),
              //   builder:
              //       (BuildContext context, AsyncSnapshot<Position> snapshot) {
              //     if (snapshot.hasData) {
              //       return Text(
              //           'Location: ${snapshot.data!.latitude}, ${snapshot.data!.longitude}');
              //     } else if (snapshot.hasError) {
              //       return Text('Error: ${snapshot.error}');
              //     } else {
              //       return const Text('Loading...');
              //     }
              //   },
              // ),
              // FutureBuilder<String>(
              //   future: _getIPAddress(),
              //   builder:
              //       (BuildContext context, AsyncSnapshot<String> snapshot) {
              //     if (snapshot.hasData) {
              //       return Text('IP Address: ${snapshot.data}');
              //     } else if (snapshot.hasError) {
              //       return Text('Error: ${snapshot.error}');
              //     } else {
              //       return const Text('Loading...');
              //     }
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Image.asset(
      "assets/images/morning-logo.png",
      height: 50,
    );
  }
}
