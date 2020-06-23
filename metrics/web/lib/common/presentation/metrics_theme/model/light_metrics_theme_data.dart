import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/metrics_theme/config/color_config.dart';
import 'package:metrics/common/presentation/metrics_theme/model/add_project_group_card_theme.dart';
import 'package:metrics/common/presentation/metrics_theme/model/build_results_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metric_widget_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metrics_circle_percentage_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metrics_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/project_group_card_theme.dart';

/// Stores the theme data for light metrics theme.
class LightMetricsThemeData extends MetricsThemeData {
  /// Creates the light theme with the default widget theme configuration.
  const LightMetricsThemeData()
      : super(
          metricCirclePercentageThemeData:
              const MetricCirclePercentageThemeData(
            lowPercentTheme: MetricWidgetThemeData(
              primaryColor: ColorConfig.accentColor,
              accentColor: Colors.transparent,
              backgroundColor: ColorConfig.accentTranslucentColor,
              textStyle: TextStyle(
                color: ColorConfig.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            mediumPercentTheme: MetricWidgetThemeData(
              primaryColor: ColorConfig.yellow,
              accentColor: Colors.transparent,
              backgroundColor: ColorConfig.yellowTranslucent,
              textStyle: TextStyle(
                color: ColorConfig.yellow,
                fontWeight: FontWeight.bold,
              ),
            ),
            highPercentTheme: MetricWidgetThemeData(
              primaryColor: ColorConfig.primaryColor,
              accentColor: Colors.transparent,
              backgroundColor: ColorConfig.primaryTranslucentColor,
              textStyle: TextStyle(
                color: ColorConfig.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          metricWidgetTheme: const MetricWidgetThemeData(
            primaryColor: ColorConfig.primaryColor,
            accentColor: ColorConfig.primaryTranslucentColor,
            backgroundColor: Colors.white,
            textStyle: TextStyle(
              color: ColorConfig.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          buildResultTheme: const BuildResultsThemeData(
            canceledColor: ColorConfig.accentColor,
            successfulColor: ColorConfig.primaryColor,
            failedColor: ColorConfig.accentColor,
          ),
          projectGroupCardTheme: const ProjectGroupCardTheme(
            borderColor: ColorConfig.borderDarkColor,
            hoverColor: ColorConfig.hoverColor,
            backgroundColor: ColorConfig.darkScaffoldColor,
            deleteColor: ColorConfig.accentColor,
            editColor: ColorConfig.primaryColor,
          ),
          addProjectGroupCardTheme: const AddProjectGroupCardTheme(
            primaryColor: ColorConfig.primaryColor,
            backgroundColor: ColorConfig.primaryTranslucentColor,
          ),
          inactiveWidgetTheme: const MetricWidgetThemeData(
            primaryColor: ColorConfig.lightInactiveColor,
            accentColor: Colors.transparent,
            backgroundColor: ColorConfig.lightInactiveBackgroundColor,
            textStyle: TextStyle(
              color: Colors.grey,
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
}
