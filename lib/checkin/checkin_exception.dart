class CheckInException implements Exception {
  final String message;
  CheckInException(this.message);

  @override
  String toString() {
    return "CheckInException(message: $message)";
  }
}

class AlreadyCheckedInException implements Exception {
  final String message;
  AlreadyCheckedInException(this.message);
}

class InvalidIpAddressException implements Exception {
  final String message;
  InvalidIpAddressException(this.message);
}

class InvalidPlaceException implements Exception {
  final String message;
  InvalidPlaceException(this.message);
}

class NotCommittedException implements Exception {
  final String message;
  NotCommittedException(this.message);
}
