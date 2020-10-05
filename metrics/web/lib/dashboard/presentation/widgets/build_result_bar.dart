import 'package:flutter/material.dart';
import 'package:metrics/base/presentation/graphs/placeholder_bar.dart';
import 'package:metrics/base/presentation/widgets/base_popup.dart';
import 'package:metrics/base/presentation/widgets/circle_graph_indicator.dart';
import 'package:metrics/base/presentation/widgets/tappable_area.dart';
import 'package:metrics/common/presentation/graph_indicator/widgets/cancelled_circle_graph_indicator.dart';
import 'package:metrics/common/presentation/graph_indicator/widgets/failed_graph_indicator.dart';
import 'package:metrics/common/presentation/graph_indicator/widgets/successful_graph_indicator.dart';
import 'package:metrics/common/presentation/metrics_theme/config/dimensions_config.dart';
import 'package:metrics/common/presentation/metrics_theme/widgets/metrics_theme.dart';
import 'package:metrics/common/presentation/widgets/metrics_colored_bar.dart';
import 'package:metrics/dashboard/presentation/view_models/build_result_view_model.dart';
import 'package:metrics/dashboard/presentation/widgets/metrics_result_bar_popup_card.dart';
import 'package:metrics/dashboard/presentation/widgets/strategy/build_result_bar_style_strategy.dart';
import 'package:metrics_core/metrics_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A single bar for a [BarGraph] widget that displays the
/// result of a [BuildResultViewModel] instance.
///
/// Displays the [PlaceholderBar] if either [buildResult] or
/// [BuildResultViewModel.buildStatus] is `null`.
class BuildResultBar extends StatefulWidget {
  /// A [BuildResultViewModel] to display.
  final BuildResultViewModel buildResult;

  /// Creates the [BuildResultBar] with the given [buildResult].
  const BuildResultBar({Key key, this.buildResult}) : super(key: key);

  @override
  _BuildResultBarState createState() => _BuildResultBarState();
}

class _BuildResultBarState extends State<BuildResultBar> {
  /// A width of the [BasePopup.popup].
  static const _popupWidth = 146.0;

  /// A top padding of the [BasePopup.popup] from the [CircleGraphIndicator].
  static const _topPadding = 4.0;

  /// A [UniqueKey] for the [VisibilityDetector].
  final _uniqueKey = UniqueKey();

  /// Indicates whether the [CircleGraphIndicator] is visible.
  bool _isCircleIndicatorVisible = true;

  @override
  Widget build(BuildContext context) {
    const radius = DimensionsConfig.circleGraphIndicatorOuterDiameter / 2.0;
    final metricsTheme = MetricsTheme.of(context);

    if (widget.buildResult == null || widget.buildResult.buildStatus == null) {
      final inactiveTheme = metricsTheme.inactiveWidgetTheme;
      return PlaceholderBar(
        width: 10.0,
        height: 4.0,
        color: inactiveTheme.primaryColor,
      );
    }

    final circleGraphIndicator = _getCircleGraphIndicator(
      widget.buildResult.buildStatus,
    );

    return LayoutBuilder(builder: (
      BuildContext context,
      BoxConstraints constraints,
    ) {
      final barHeight = constraints.minHeight;

      return BasePopup(
        isPopupOpaque: false,
        closePopupWhenTapOutside: false,
        popupConstraints: const BoxConstraints(
          minWidth: _popupWidth,
          maxWidth: _popupWidth,
        ),
        offsetBuilder: (Size childSize) {
          final height = childSize.height;
          final dx = childSize.width / 2.0 - _popupWidth / 2.0;
          final dy = _isCircleIndicatorVisible
              ? height - barHeight + _topPadding + radius
              : height;

          return Offset(dx, dy);
        },
        triggerBuilder: (context, openPopup, closePopup, _) {
          return MouseRegion(
            onEnter: (_) => openPopup(),
            onExit: (_) => closePopup(),
            child: TappableArea(
              onTap: _onBarTap,
              builder: (context, isHovered, _) {
                const strategy = BuildResultBarStyleStrategy();

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    MetricsColoredBar(
                      isHovered: isHovered,
                      height: barHeight,
                      barStrategy: strategy,
                      status: widget.buildResult.buildStatus,
                    ),
                    Positioned(
                      bottom: barHeight - radius,
                      child: VisibilityDetector(
                        key: _uniqueKey,
                        onVisibilityChanged: (VisibilityInfo info) {
                          _isCircleIndicatorVisible =
                              info.visibleFraction != 0.0;

                          if (isHovered) {
                            closePopup();
                            openPopup();
                          }
                        },
                        child: Opacity(
                          opacity: isHovered ? 1.0 : 0.0,
                          child: circleGraphIndicator,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
        popup: MetricsResultBarPopupCard(
          dashboardPopupCardViewModel:
              widget.buildResult.dashboardPopupCardViewModel,
        ),
      );
    });
  }

  /// Select the [MetricsCircleGraphIndicator] widget to use
  /// based on [buildStatus].
  Widget _getCircleGraphIndicator(BuildStatus buildStatus) {
    switch (buildStatus) {
      case BuildStatus.successful:
        return const SuccessfulGraphIndicator();
      case BuildStatus.cancelled:
        return const CancelledGraphIndicator();
      case BuildStatus.failed:
        return const FailedGraphIndicator();
      default:
        return null;
    }
  }

  /// Opens the [BuildResultViewModel.url].
  Future<void> _onBarTap() async {
    final url = widget.buildResult.url;
    if (url == null) return;

    final canLaunchUrl = await canLaunch(url);

    if (canLaunchUrl) {
      await launch(url);
    }
  }
}
