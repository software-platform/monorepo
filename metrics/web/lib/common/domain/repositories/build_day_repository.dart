// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:metrics/common/domain/entities/build_day.dart';

/// A base class for build days repositories.
///
/// Provides an ability to get the build day data.
abstract class BuildDayRepository {
  /// Provides a stream of [BuildDay]s related to a project with the
  /// given [projectId].
  ///
  /// Throws an [ArgumentError] if the given [projectId] is `null`.
  ///
  /// Requests build days within the specified date range using given
  /// [from] and [to] timestamps.
  ///
  /// Does not apply the given [from] timestamp if it is `null`.
  /// Does not apply the given [to] timestamp if it is `null`.
  Stream<List<BuildDay>> projectBuildDaysInDateRangeStream(
    String projectId, {
    DateTime from,
    DateTime to,
  });
}
