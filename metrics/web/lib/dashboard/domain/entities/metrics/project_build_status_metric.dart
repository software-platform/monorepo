import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:metrics_core/metrics_core.dart';

/// A class that represents a project build status metric.
@immutable
class ProjectBuildStatusMetric extends Equatable {
  /// Provides an information about the status of the project build.
  final BuildStatus status;

  @override
  List<Object> get props => [status];

  /// Creates a [ProjectBuildStatusMetric].
  const ProjectBuildStatusMetric({this.status});
}
