class DateStatus {
  final DateTime date;
  final bool enabled;
  final String? time;
  final int? point;

  DateStatus({
    required this.date,
    this.enabled = false,
    this.time,
    this.point,
  });

  @override
  String toString() {
    return "DateStatus: $date, $enabled, $time, $point";
  }
}
