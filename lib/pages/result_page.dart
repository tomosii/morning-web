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

  @override
  void initState() {
    super.initState();
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
            ],
          ),
        ),
      ),
    );
  }
}
