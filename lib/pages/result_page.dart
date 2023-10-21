import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morning_web/providers/providers.dart';
import 'package:morning_web/utils/ip_address.dart';
import 'package:morning_web/utils/location.dart';
import 'package:morning_web/verification/condition_status.dart';

import '../../constants/colors.dart';
import '../components/ripple_animation.dart';

class CheckInResultPage extends ConsumerStatefulWidget {
  const CheckInResultPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckInResultPage> createState() => _CheckInResultPageState();
}

class _CheckInResultPageState extends ConsumerState<CheckInResultPage>
    with TickerProviderStateMixin {
  double _titleOpacity = 0;
  double _formOpacity = 0;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.topCenter,
        constraints: const BoxConstraints(
          maxWidth: 400,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              _logo(),
              const SizedBox(
                height: 20,
              ),
              _currentDateAndTime(),
              const SizedBox(
                height: 40,
              ),
              _statusPanel(),
              const SizedBox(
                height: 100,
              ),
              _showCheckInButton(),
              const SizedBox(
                height: 100,
              ),
              _debugInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Image.asset(
      'assets/images/morning-logo.png',
      height: 45,
    );
  }

  Widget _currentDateAndTime() {
    return StreamBuilder<DateTime>(
      stream:
          Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
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
    );
  }

  Widget _statusPanel() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
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
            ref.watch(networkStatusProvider).when(
                  data: (networkStatus) {
                    if (networkStatus == NetworkStatus.valid) {
                      return _statusRow(
                        Icons.wifi_rounded,
                        morningBlue,
                        "指定のネットワークに接続されています",
                      );
                    } else {
                      return _statusRow(
                        Icons.wifi_off_rounded,
                        morningPink,
                        "指定のネットワークに接続されていません",
                      );
                    }
                  },
                  loading: () => _statusRow(
                    Icons.wifi,
                    Colors.black.withOpacity(0.2),
                    "ネットワーク情報を取得中...",
                  ),
                  error: (error, stackTrace) => _statusRow(
                    Icons.wifi_off_rounded,
                    morningPink,
                    "ネットワーク情報を取得できませんでした",
                  ),
                ),
            const SizedBox(
              height: 8,
            ),
            ref.watch(locationStatusProvider).when(
                  data: (locationStatus) {
                    if (locationStatus == LocationStatus.withinRange) {
                      return _statusRow(
                        Icons.gps_fixed,
                        morningBlue,
                        "チェックインエリア圏内です",
                      );
                    } else if (locationStatus == LocationStatus.outOfRange) {
                      return _statusRow(
                        Icons.gps_off,
                        morningPink,
                        "チェックインエリア圏外です",
                      );
                    } else if (locationStatus == LocationStatus.notAvailable) {
                      return _statusRow(
                        Icons.location_disabled_rounded,
                        morningPink,
                        "位置情報を取得できませんでした",
                      );
                    } else if (locationStatus == LocationStatus.mocking) {
                      return _statusRow(
                        Icons.location_disabled_rounded,
                        morningPink,
                        "位置情報が偽装されています",
                      );
                    } else {
                      return _statusRow(
                        Icons.location_disabled_rounded,
                        morningPink,
                        "位置情報を取得できませんでした",
                      );
                    }
                  },
                  loading: () => _statusRow(
                    Icons.gps_not_fixed,
                    Colors.black.withOpacity(0.2),
                    "位置情報を取得中...",
                  ),
                  error: (error, stackTrace) => _statusRow(
                    Icons.location_disabled_rounded,
                    morningPink,
                    "位置情報を取得できませんでした",
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
        ),
        const SizedBox(
          width: 15,
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.65),
            ),
          ),
        ),
      ],
    );
  }

  Widget _showCheckInButton() {
    return ref.watch(isCheckInAvailableProvider).when(
          data: (isCheckInAvailable) {
            if (isCheckInAvailable) {
              return CustomPaint(
                painter: CircleRipplePainter(
                  _controller,
                  color: morningBlue,
                ),
                child: _checkInButton(true),
              );
            } else {
              return _checkInButton(false);
            }
          },
          loading: () => _checkInButton(false),
          error: (error, stackTrace) => _checkInButton(false),
        );
  }

  Widget _checkInButton(bool enabled) {
    return Center(
      child: SizedBox(
        width: 160,
        height: 160,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(
              side: BorderSide(
                color: Colors.black.withOpacity(0.07),
                width: enabled ? 0 : 2,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.all(0),
          ),
          onPressed: () {
            // if (enabled) {
            //   Navigator.pushNamed(context, "/checkin");
            // }
          },
          child: Icon(
            Icons.brightness_7,
            color: enabled ? morningBlue : Colors.black.withOpacity(0.2),
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget _debugInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<String>(
          future: getIPAddress(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Text(
                snapshot.data!,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.black.withOpacity(0.3),
                ),
              );
            } else if (snapshot.hasError) {
              return Text(
                snapshot.error.toString(),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.black.withOpacity(0.3),
                ),
              );
            }
            return Container();
          },
        ),
        FutureBuilder<Position>(
          future: getCurrentPosition(),
          builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
            if (snapshot.hasData) {
              return Text(
                "${snapshot.data!.latitude}, ${snapshot.data!.longitude}",
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.black.withOpacity(0.3),
                ),
              );
            } else if (snapshot.hasError) {
              return Text(
                snapshot.error.toString(),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.black.withOpacity(0.3),
                ),
              );
            }
            return Container();
          },
        ),
      ],
    );
  }
}