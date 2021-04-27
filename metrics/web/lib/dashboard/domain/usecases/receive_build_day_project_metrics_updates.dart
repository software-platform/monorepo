// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:metrics/base/domain/usecases/usecase.dart';
import 'package:metrics/common/domain/entities/build_day.dart';
import 'package:metrics/common/domain/repositories/build_day_repository.dart';
import 'package:metrics/dashboard/domain/entities/collections/date_time_set.dart';
import 'package:metrics/dashboard/domain/entities/metrics/build_day_project_metrics.dart';
import 'package:metrics/dashboard/domain/entities/metrics/build_number_metric.dart';
import 'package:metrics/dashboard/domain/entities/metrics/build_performance.dart';
import 'package:metrics/dashboard/domain/entities/metrics/performance_metric.dart';
import 'package:metrics/dashboard/domain/usecases/parameters/project_id_param.dart';

/// A [UseCase] that stands for loading the [BuildDayProjectMetrics].
class ReceiveBuildDayProjectMetricsUpdates
    implements UseCase<Stream<BuildDayProjectMetrics>, ProjectIdParam> {
  /// A [Duration] of a loading period for builds.
  static const Duration metricsLoadingPeriod = Duration(days: 6);

  /// A [BuildDayRepository] this use case uses to load the data from
  /// the remote.
  final BuildDayRepository _repository;

  /// Creates a new instance of the [ReceiveBuildDayProjectMetricsUpdates]
  /// with given [BuildDayRepository].
  ///
  /// Throws an [ArgumentError] if the given [BuildDayRepository] is `null`.
  ReceiveBuildDayProjectMetricsUpdates(this._repository) {
    ArgumentError.checkNotNull(_repository, '_repository');
  }

  @override
  Stream<BuildDayProjectMetrics> call(ProjectIdParam params) {
    final projectId = params.projectId;
    final dateFrom = DateTime.now().subtract(metricsLoadingPeriod);

    final buildDayStream = _repository.projectBuildDaysInDateRangeStream(
      projectId,
      from: dateFrom,
    );

    return buildDayStream.map(
      (buildDays) => _mapBuildDaysToMetrics(buildDays, projectId),
    );
  }

  /// Maps the given [buildDays] of the project with the given [projectId]
  /// to the [BuildDayProjectMetrics].
  BuildDayProjectMetrics _mapBuildDaysToMetrics(
    List<BuildDay> buildDays,
    String projectId,
  ) {
    final buildNumberMetric = _createBuildNumberMetric(buildDays);
    final performanceMetric = _createPerformanceMetric(buildDays);

    return BuildDayProjectMetrics(
      projectId: projectId,
      buildNumberMetric: buildNumberMetric,
      performanceMetric: performanceMetric,
    );
  }

  /// Creates a [BuildNumberMetric] based on the given [buildDays].
  BuildNumberMetric _createBuildNumberMetric(List<BuildDay> buildDays) {
    final numberOfBuildsInPeriod = _getTotalNumberOfBuildsInPeriod(buildDays);

    return BuildNumberMetric(numberOfBuilds: numberOfBuildsInPeriod);
  }

  /// Creates a [PerformanceMetric] based on the given [buildDays].
  PerformanceMetric _createPerformanceMetric(List<BuildDay> buildDays) {
    final averageDuration = _calculateAverageDuration(buildDays);
    final buildsPerformance = buildDays.map(_mapBuildDayToPerformance);

    return PerformanceMetric(
      averageBuildDuration: averageDuration,
      buildsPerformance: DateTimeSet.from(buildsPerformance),
    );
  }

  /// Calculates the average [BuildDay.totalDuration] of the given [buildDays].
  ///
  /// Returns a [Duration.zero] if the total number of builds performed during
  /// the given [buildDays] is `null`.
  Duration _calculateAverageDuration(List<BuildDay> buildDays) {
    final numberOfBuildsInPeriod = _getTotalNumberOfBuildsInPeriod(buildDays);

    if (numberOfBuildsInPeriod == 0) return Duration.zero;

    final totalDurationInPeriod = _getTotalDurationOfBuildsInPeriod(buildDays);

    return totalDurationInPeriod ~/ numberOfBuildsInPeriod;
  }

  /// Returns the total number of builds performed during the given [buildDays].
  int _getTotalNumberOfBuildsInPeriod(List<BuildDay> buildDays) {
    return buildDays.fold<int>(
      0,
      (value, buildDay) => value + _getNumberOfBuildsInDay(buildDay),
    );
  }

  /// Returns the sum of build [Duration]s performed during the given [buildDays].
  Duration _getTotalDurationOfBuildsInPeriod(List<BuildDay> buildDays) {
    return buildDays.fold<Duration>(
      Duration.zero,
      (value, buildDay) => value + buildDay.totalDuration,
    );
  }

  /// Returns the number of builds performed during the given [buildDay].
  int _getNumberOfBuildsInDay(BuildDay buildDay) {
    return buildDay.successful +
        buildDay.failed +
        buildDay.unknown +
        buildDay.inProgress;
  }

  /// Maps the given [buildDay] to [BuildPerformance].
  BuildPerformance _mapBuildDayToPerformance(BuildDay buildDay) {
    return BuildPerformance(
      date: buildDay.day,
      duration: buildDay.totalDuration,
    );
  }
}
