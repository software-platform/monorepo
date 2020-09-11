import 'package:metrics/common/presentation/metrics_theme/model/project_build_status/style/project_build_status_style.dart';
import 'package:metrics/common/presentation/metrics_theme/widgets/strategy/value_based_appearance_strategy.dart';
import 'package:metrics_core/metrics_core.dart';

/// A base class for a theme strategy based on the [BuildStatus] value.
///
/// Represents the strategy of applying the [ProjectBuildStatusStyle] to the metrics widgets.
abstract class BuildStatusStyleStrategy
    implements
        ValueBasedAppearanceStrategy<ProjectBuildStatusStyle, BuildStatus> {
  /// Returns the icon image, based on the [BuildStatus] value.
  String getIconImage(BuildStatus value);
}
