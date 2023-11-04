import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morning_web/components/error_dialog.dart';
import 'package:morning_web/providers/providers.dart';
import 'package:morning_web/repository/checkin.dart';
import 'package:morning_web/utils/ip_address.dart';
import 'package:morning_web/utils/location.dart';
import 'package:morning_web/checkin/condition_status.dart';
import 'package:sprung/sprung.dart';

import '../../constants/colors.dart';
import '../components/ripple_animation.dart';
import '../utils/date.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  double _headerOpacity = 0;
  double _bgOpacity = 0;
  double _statusOpacity = 0;
  double _buttonOpacity = 0;

  double _statusPanelScale = 0;

  bool _checkInLoading = false;

  late final AnimationController _rippleAnimController;

  @override
  void initState() {
    super.initState();
    _rippleAnimController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _headerOpacity = 1;
        _bgOpacity = 0.5;
      });
    });

    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        _statusOpacity = 1;
        _statusPanelScale = 1;
      });
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _buttonOpacity = 1;
      });
    });
  }

  @override
  void dispose() {
    _rippleAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        heightFactor: 1,
        child: SingleChildScrollView(
          // physics: const AlwaysScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          padding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -130,
                top: -100,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: _bgOpacity,
                  child: Image.asset(
                    "assets/images/yellow-circle.png",
                    width: 280,
                    height: 280,
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 30,
                  sigmaY: 30,
                ),
                child: Container(
                  alignment: Alignment.topCenter,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 1600),
      opacity: _headerOpacity,
      child: Image.asset(
        'assets/images/morning-logo.png',
        height: 45,
      ),
    );
  }

  Widget _currentDateAndTime() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 1600),
      opacity: _headerOpacity,
      child: StreamBuilder<DateTime>(
        stream: Stream.periodic(
            const Duration(milliseconds: 100), (_) => DateTime.now()),
        builder: (BuildContext context, AsyncSnapshot<DateTime> snap) {
          if (snap.hasData) {
            final DateTime now = snap.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${now.year}年${now.month}月${now.day}日 (${getJPTodayDayOfWeek()})",
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
    );
  }

  Widget _statusPanel() {
    return AnimatedScale(
      duration: const Duration(milliseconds: 3500),
      scale: _statusPanelScale,
      curve: Sprung.overDamped,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 1400),
        opacity: _statusOpacity,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(14)),
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
              vertical: 24,
            ),
            child: Column(
              children: [
                ref.watch(networkStatusProvider).when(
                      data: (networkStatus) {
                        if (networkStatus == NetworkStatus.valid) {
                          return _statusRow(
                            icon: Icons.wifi_rounded,
                            color: morningBlue,
                            text: "指定のネットワークに接続されています",
                            detail: ref.watch(networkDestinationProvider),
                          );
                        } else {
                          return _statusRow(
                            icon: Icons.wifi_off_rounded,
                            color: morningPink,
                            text: "指定のネットワークに接続されていません",
                          );
                        }
                      },
                      loading: () => _statusRow(
                        icon: Icons.wifi,
                        color: Colors.black.withOpacity(0.2),
                        text: "ネットワーク情報を取得中...",
                      ),
                      error: (error, stackTrace) => _statusRow(
                        icon: Icons.wifi_off_rounded,
                        color: morningPink,
                        text: "ネットワーク情報を取得できませんでした",
                      ),
                    ),
                const SizedBox(
                  height: 14,
                ),
                ref.watch(locationStatusProvider).when(
                      data: (locationStatus) {
                        if (locationStatus == LocationStatus.withinRange) {
                          String place = ref.watch(networkDestinationProvider);
                          if (place == "") {
                            place = ref.watch(locationNameProvider);
                          }
                          final distance =
                              ref.watch(locationDistanceProvider).toInt();
                          return _statusRow(
                            icon: Icons.gps_fixed,
                            color: morningBlue,
                            text: "チェックインエリア圏内です",
                            detail: "${place} から${distance}m",
                          );
                        } else if (locationStatus ==
                            LocationStatus.outOfRange) {
                          return _statusRow(
                            icon: Icons.gps_off,
                            color: morningPink,
                            text: "チェックインエリア圏外です",
                          );
                        } else if (locationStatus ==
                            LocationStatus.notAvailable) {
                          return _statusRow(
                            icon: Icons.location_disabled_rounded,
                            color: morningPink,
                            text: "位置情報を取得できませんでした",
                          );
                        } else if (locationStatus == LocationStatus.mocking) {
                          return _statusRow(
                            icon: Icons.location_disabled_rounded,
                            color: morningPink,
                            text: "位置情報が偽装されています",
                          );
                        } else {
                          return _statusRow(
                            icon: Icons.location_disabled_rounded,
                            color: morningPink,
                            text: "位置情報を取得できませんでした",
                          );
                        }
                      },
                      loading: () => _statusRow(
                        icon: Icons.gps_not_fixed,
                        color: Colors.black.withOpacity(0.2),
                        text: "位置情報を取得中...",
                      ),
                      error: (error, stackTrace) => _statusRow(
                        icon: Icons.location_disabled_rounded,
                        color: morningPink,
                        text: "位置情報を取得できませんでした",
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusRow({
    required IconData icon,
    required Color color,
    required String text,
    String? detail,
  }) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(0.65),
                ),
              ),
              if (detail != null) ...[
                const SizedBox(
                  height: 3,
                ),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _showCheckInButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 1400),
      opacity: _buttonOpacity,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 2500),
              opacity: ref.watch(checkInButtonRippleOpacityProvider),
              child: CustomPaint(
                painter: CircleRipplePainter(
                  _rippleAnimController,
                  color: morningBlue,
                ),
                child: const SizedBox(
                  width: 160,
                  height: 160,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ref.watch(isCheckInAvailableProvider).when(
                  data: (isCheckInAvailable) {
                    if (isCheckInAvailable) {
                      return _checkInButton(true);
                    } else {
                      return _checkInButton(false);
                    }
                  },
                  loading: () => _checkInButton(false),
                  error: (error, stackTrace) => _checkInButton(false),
                ),
          ),
        ],
      ),
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
            if (!enabled || _checkInLoading) {
              return;
            }
            _checkInAndPush();
          },
          child: _checkInLoading
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: morningBlue,
                    strokeWidth: 3,
                  ),
                )
              : Icon(
                  Icons.brightness_7,
                  color: enabled ? morningBlue : Colors.black.withOpacity(0.2),
                  size: 35,
                ),
        ),
      ),
    );
  }

  Widget _debugInfo() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 1400),
      opacity: _buttonOpacity,
      child: Column(
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
      ),
    );
  }

  Future<void> _checkInAndPush() async {
    setState(() {
      _checkInLoading = true;
    });

    print("チェックイン処理を開始");

    final email = ref.read(userEmailProvider)!;
    print("IPアドレスを取得中...");
    final ipAddress = await getIPAddress();
    print("位置情報を取得中...");
    final currentPosition = await getCurrentPosition();

    try {
      final result = await CheckInRepository().checkIn(
        email,
        ipAddress,
        currentPosition.latitude,
        currentPosition.longitude,
      );
      print("Check-in result: $result");
      ref.read(checkInResultProvider.notifier).state = result;
    } on Exception catch (error) {
      showDialog(
        context: context,
        builder: (_) {
          return MorningErrorDialog(
            title: "チェックインに失敗しました",
            message: error.toString(),
          );
        },
      );
      setState(() {
        _checkInLoading = false;
      });

      // 場所を再取得することで、ステータスを再評価 -> 画面更新
      ref.invalidate(checkInPlacesProvider);

      return;
    }

    setState(() {
      _checkInLoading = false;
    });
    Navigator.pushNamed(context, "/result");
  }
}
