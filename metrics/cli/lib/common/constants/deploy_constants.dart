// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

/// A class that holds the constants for the deployment process.
class DeployConstants {
  /// A URL to the Metrics repository.
  static const String repoURL = 'https://github.com/Flank/flank-dashboard';

  /// A Firebase Hosting target name.
  static const String firebaseTarget = 'metrics';

  /// A Sentry environment name.
  static const String sentryEnvironment = 'metrics';

  /// A temporary directory prefix.
  static const String tempDirectoryPrefix = 'metrics_';
}
