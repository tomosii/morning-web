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
  double _titleOpacity = 0;
  double _formOpacity = 0;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
    Future.delayed(const Duration(milliseconds: 1000), () {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.only(
                  right: 20,
                ),
                // fromat current datetime
                child: Text(
                  DateFormat("yyyy/MM/dd HH:mm").format(DateTime.now()),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              const Icon(
                Icons.place,
                size: 47,
                color: morningBlue,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                "Studio",
                style: GoogleFonts.montserrat(
                  fontSize: 47,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "-1時間7分",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: morningBlue,
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${ref.watch(userNameProvider)}さん、おはようございます。",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black.withOpacity(0.8)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "ギリギリセーフです！",
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
                  Navigator.of(context).pop();
                },
                text: "OK",
                width: 140,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
