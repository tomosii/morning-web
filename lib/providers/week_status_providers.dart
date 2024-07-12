import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/commitment.dart';
import '../models/date_status.dart';
import '../repository/commitment.dart';
import '../utils/date.dart';
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

final thisWeekStatusProvider =
    FutureProvider.autoDispose<List<DateStatus>?>((ref) async {
  final userCommitment = await ref.watch(thisWeekCommitmentsProvider.future);
  final weekdays = getOngoingOrComingWeekdays();

  if (userCommitment == null) {
    return null;
  }

  if (userCommitment.dates!.length > 5) {
    throw Exception("Too many commitments in a week");
  }

  List<DateStatus> dateStatusList = [];
  for (final weekday in weekdays) {
    bool commitEnabled = false;
    for (var commitDate in userCommitment.dates!) {
      if (isSameDate(weekday, commitDate)) {
        commitEnabled = true;
        break;
      }
    }

    if (commitEnabled) {
      dateStatusList.add(
        DateStatus(
          date: weekday,
          enabled: true,
          time: userCommitment.time,
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
});
