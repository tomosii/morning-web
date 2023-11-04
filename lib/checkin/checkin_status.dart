enum NetworkStatus {
  invalid,
  valid,
}

enum LocationStatus {
  withinRange,
  outOfRange,
  notAvailable,
  mocking,
}

enum CheckInProcessStatus {
  notStarted,
  fetchingNetwork,
  fetchingLocation,
  connectingToServer,
  done,
}
