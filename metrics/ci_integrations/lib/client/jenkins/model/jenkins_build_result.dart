/// Enum that represents the jenkins build result code.
enum JenkinsBuildResult {
  /// Indicates that the build was manually aborted.
  aborted,

  /// Indicates that the module was not built.
  /// This status code is used in a multi-stage build (like maven2)
  /// where a problem in earlier stage prevented later stages from building.
  notBuild,

  /// Indicates that the build had a fatal error.
  failure,

  /// Indicates that the build had some errors but they were not fatal.
  unstable,

  /// Indicates that the build had no errors.
  success,
}
