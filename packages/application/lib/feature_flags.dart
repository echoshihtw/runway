/// Build-time switches.
abstract final class FeatureFlags {
  /// Local development override for paid features.
  ///
  /// Enable with:
  /// `--dart-define=DEV_PRO_ENTITLEMENT=true`
  static const devProEntitlement =
      !bool.fromEnvironment('dart.vm.product') &&
      bool.fromEnvironment('DEV_PRO_ENTITLEMENT');
}
