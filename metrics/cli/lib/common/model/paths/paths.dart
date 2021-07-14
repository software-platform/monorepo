// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:equatable/equatable.dart';

/// A class that holds common paths based on the current root directory path.
class Paths extends Equatable {
  /// A path to the root directory.
  final String rootPath;

  @override
  List<Object> get props => [rootPath];

  /// Creates a new instance of the [Paths] with the given [rootPath].
  ///
  /// Throws an [ArgumentError] if the given [rootPath] is `null`.
  Paths(this.rootPath) {
    ArgumentError.checkNotNull(rootPath, 'rootPath');
  }

  /// A path to the Metrics Web project sources.
  String get webAppPath => '$rootPath/metrics/web';

  /// A path to the built directory of the Metrics Web project.
  String get webAppBuildPath => '$webAppPath/build/web';

  /// A path to the Firebase sources.
  String get firebasePath => '$rootPath/metrics/firebase';

  /// A path to the Firebase functions sources.
  String get firebaseFunctionsPath => '$firebasePath/functions';

  /// A path to the Metrics configuration file.
  String get metricsConfigPath => '$webAppPath/build/web/metrics_config.js';
}
