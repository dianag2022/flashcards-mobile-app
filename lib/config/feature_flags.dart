class FeatureFlags {
  FeatureFlags._();

  /// Home cards for due review and overall mastery.
  /// Hidden automatically if progress endpoints fail.
  static const bool homeProgressInsights = true;
}
