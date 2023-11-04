import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morning_web/providers/providers.dart';

import '../../constants/colors.dart';

class CheckInLoadingPage extends ConsumerStatefulWidget {
  const CheckInLoadingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckInLoadingPage> createState() => _CheckInLoadingPageState();
}

class _CheckInLoadingPageState extends ConsumerState<CheckInLoadingPage>
    with TickerProviderStateMixin {
  double _placeOpacity = 0;
  double _timeOpacity = 0;
  double _messageOpacity = 0;

  late ConfettiController _confettiController;

  LinearGradient _bgGradient = const LinearGradient(
    colors: [
      morningBlue,
      morningBlue,
    ],
  );

  final List<LinearGradient> _gradients = [
    const LinearGradient(
      colors: [
        morningBlue,
        Color(0xFF3DAFE0),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [
        morningBlue,
        Color(0xFF3DAFE0),
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
    const LinearGradient(
      colors: [
        morningBlue,
        Color(0xFF3D74E0),
      ],
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ),
    const LinearGradient(
      colors: [
        morningBlue,
        Color(0xFF3D74E0),
      ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  ];

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _bgGradient = _gradients.last;
      });
    });

    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        _bgGradient = _gradients[timer.tick % _gradients.length];
      });
    });

    // Future.delayed(const Duration(milliseconds: 300), () {
    //   setState(() {
    //     _placeOpacity = 1;
    //   });
    // });

    // Future.delayed(const Duration(milliseconds: 900), () {
    //   setState(() {
    //     _timeOpacity = 1;
    //   });
    // });

    // Future.delayed(const Duration(milliseconds: 1500), () {
    //   setState(() {
    //     _messageOpacity = 1;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(checkInProcessStatusProvider);

    return Scaffold(
      backgroundColor: morningBlue,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: _bgGradient,
        ),
        child: Center(
          heightFactor: 1.0,
          child: Container(
            alignment: Alignment.topCenter,
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  status.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
