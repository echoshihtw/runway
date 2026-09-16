import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// The one place that maps a runway status to a colour.
///
/// Caution is amber, not gold, because gold means debt and loan obligations
/// (CONTRACTS.md §4.1). The runway number sits directly above the gold
/// liabilities card, so sharing the colour made them read as one category.
Color statusColor(SurvivalStatus status) => switch (status) {
  SurvivalStatus.stable => SC.statusStable,
  SurvivalStatus.caution => SC.statusCaution,
  SurvivalStatus.critical => SC.statusCritical,
};
