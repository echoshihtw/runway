enum RunwayStatus {
  stable,
  caution,
  critical;

  String get label => switch (this) {
    RunwayStatus.stable => 'STABLE',
    RunwayStatus.caution => 'CAUTION',
    RunwayStatus.critical => 'CRITICAL',
  };
}
