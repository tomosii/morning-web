import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morning_web/components/primary_button.dart';
import 'package:intl/intl.dart';
import 'package:morning_web/providers/providers.dart';

import '../../constants/colors.dart';

class CheckInResultPage extends ConsumerStatefulWidget {
  const CheckInResultPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckInResultPage> createState() => _CheckInResultPageState();
}

class _CheckInResultPageState extends ConsumerState<CheckInResultPage>
    with TickerProviderStateMixin {
  double _placeOpacity = 0;
  double _timeOpacity = 0;
  double _messageOpacity = 0;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
    Future.delayed(const Duration(milliseconds: 1000), () {
      _confettiController.play();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _placeOpacity = 1;
      });
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      setState(() {
        _timeOpacity = 1;
      });
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _messageOpacity = 1;
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkInResult = ref.watch(checkInResultProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
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
              Container(
                alignment: Alignment.centerRight,
                // fromat current datetime
                child: Text(
                  DateFormat("yyyy/MM/dd HH:mm").format(DateTime.now()),
                  style: const TextStyle(
                    fontFamily: "Inter",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: _placeOpacity,
                child: Column(
                  children: [
                    const Icon(
                      Icons.place,
                      size: 47,
                      color: morningBlue,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      checkInResult.placeName ?? "",
                      style: GoogleFonts.montserrat(
                        fontSize: 47,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: _timeOpacity,
                child: Text(
                  _parseTimeDifference(
                      checkInResult.timeDifferenceSeconds ?? 0),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ((checkInResult.timeDifferenceSeconds ?? 0) < 0)
                        ? morningBlue
                        : morningPink,
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: _messageOpacity,
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${ref.watch(userNicknameProvider)}さん、おはようございます。",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black.withOpacity(0.8)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          _message(checkInResult.timeDifferenceSeconds ?? 0),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black.withOpacity(0.8)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "チェックインを記録しました。",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black.withOpacity(0.8)),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                    PrimaryButton(
                      onTap: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          "/",
                          (_) => false,
                        );
                      },
                      text: "OK",
                      width: 140,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _parseTimeDifference(double seconds) {
    final absSeconds = seconds.abs();

    final hour = absSeconds ~/ 3600;
    final minute = (absSeconds % 3600) ~/ 60;
    final second = absSeconds.toInt() % 60;

    String timeText = "";

    if (hour == 0 && minute == 0) {
      timeText = "$second秒";
    } else if (hour == 0) {
      timeText = "$minute分$second秒";
    } else {
      timeText = "$hour時間$minute分";
    }

    if (seconds < 0) {
      return "- $timeText";
    } else {
      return "+ $timeText";
    }
  }

  String _message(double seconds) {
    final now = DateTime.now();

    final sentences = [
      "いい朝ですね！",
      "今日も一日頑張っていきましょう！",
      "朝の時間を有効に使っていきましょう！",
    ];

    if (-120 < seconds && seconds < 0) {
      return "ギリギリセーフです！";
    } else if (now.hour < 7 && now.minute < 30) {
      return "とても早い朝ですね！";
    } else if (seconds < -3600) {
      return "余裕を持っていて素晴らしいです！";
    } else if (0 <= seconds && seconds < 300) {
      return "惜しい！ あともう少しでしたね！";
    } else if (0 < seconds) {
      return "寝坊してしまいましたか？";
    } else {
      final random = Random();
      return sentences[random.nextInt(sentences.length)];
    }
  }
}
