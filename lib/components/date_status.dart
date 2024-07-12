import 'package:flutter/material.dart';
import 'package:morning_web/utils/date.dart';

import '../constants/colors.dart';

class DateStatusIndicator extends StatelessWidget {
  final DateTime date;
  final bool enabled;
  final int? point;

  const DateStatusIndicator({
    Key? key,
    required this.date,
    this.enabled = true,
    this.point,
  }) : super(key: key);

  Color get bgColor {
    if (!enabled) {
      return Colors.black.withOpacity(0.05);
    } else if (point == null) {
      return morningBgBlue;
    } else if (point! > 0) {
      return morningBlue;
    } else {
      return morningPink;
    }
  }

  Color get textColor {
    if (!enabled) {
      return Colors.black.withOpacity(0.2);
    } else if (point == null) {
      return morningFgBlue;
    } else {
      return Colors.white;
    }
  }

  Widget get child {
    if (!enabled) {
      return Container();
    } else if (point == null) {
      return Container(
        padding: const EdgeInsets.only(
          top: 6,
          bottom: 3,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getJPDayOfWeekString(date.weekday),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: textColor.withOpacity(0.5),
                height: 1.0,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontFamily: "Inter",
                fontSize: 21,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.0,
              ),
            ),
          ],
        ),
      );
    } else if (point! > 0) {
      return const Center(
          child: Icon(
        Icons.check_rounded,
        color: Colors.white,
        size: 24,
      ));
    } else {
      return Center(
        child: Text(
          point.toString(),
          style: TextStyle(
            fontFamily: "Inter",
            fontSize: 21,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: child,
    );
  }
}
