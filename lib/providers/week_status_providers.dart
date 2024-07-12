import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendance.dart';
import '../models/commitment.dart';
import '../models/date_status.dart';
import '../repository/attendance.dart';
import '../repository/commitment.dart';
import '../utils/date.dart';
import '../utils/point.dart';
import 'providers.dart';

final thisWeekCommitmentsProvider =
    FutureProvider.autoDispose<UserCommitment?>((ref) async {
  final commitRepository = ref.watch(commitmentRepositoryProvider);
  final user = await ref.watch(userProvider.future);

  if (user != null) {
    final weekdays = getOngoingOrComingWeekdays();
    final userCommitment =
        await commitRepository.getUserCommitment(user.id, weekdays);
    return userCommitment;
  }
});

final thisWeekAttendancesProvider =
    FutureProvider.autoDispose<List<Attendance>?>((ref) async {
  final attendanceRepository = ref.watch(attendanceRepositoryProvider);
  final user = await ref.watch(userProvider.future);

  if (user != null) {
    final weekdays = getOngoingOrComingWeekdays();
    final userAttendances =
        await attendanceRepository.getUserAttendances(user.id, weekdays);
    return userAttendances;
  }
});

final thisWeekStatusProvider =
    FutureProvider.autoDispose<List<DateStatus>?>((ref) async {
  try {
    final weekdays = getOngoingOrComingWeekdays();

    final userCommitment = await ref.watch(thisWeekCommitmentsProvider.future);
    final attendances = await ref.watch(thisWeekAttendancesProvider.future);

    if (userCommitment == null) {
      return null;
    }

    if (userCommitment.dates!.length > 5 || weekdays.length > 5) {
      throw Exception("Too many days in a week");
    }

    List<DateStatus> dateStatusList = [];
    for (final weekday in weekdays) {
      bool commitEnabled = false;
      int? pointChange;
      for (var commitDate in userCommitment.dates!) {
        if (isSameDate(weekday, commitDate)) {
          commitEnabled = true;
          break;
        }
      }

      if (attendances != null) {
        for (final attendance in attendances) {
          if (isSameDate(weekday, attendance.date!)) {
            pointChange = getPointChange(attendance.timeDifferenceSeconds!);
          }
        }
      }

      if (commitEnabled) {
        dateStatusList.add(
          DateStatus(
            date: weekday,
            enabled: true,
            time: userCommitment.time,
            point: pointChange,
          ),
        );
      } else {
        dateStatusList.add(DateStatus(
          date: weekday,
          enabled: false,
        ));
      }
    }

    return dateStatusList;
  } catch (e) {
    debugPrint("Failed to get this week status: $e");
    rethrow;
  }
});
