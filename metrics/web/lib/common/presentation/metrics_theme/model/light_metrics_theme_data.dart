import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/button/theme/attention_level/metrics_button_attention_level.dart';
import 'package:metrics/common/presentation/metrics_theme/config/color_config.dart';
import 'package:metrics/common/presentation/metrics_theme/config/text_style_config.dart';
import 'package:metrics/common/presentation/metrics_theme/model/build_results_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metric_widget_theme_data.dart';
import 'package:metrics/common/presentation/button/theme/theme_data/metrics_button_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metrics_circle_percentage_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metrics_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/project_group_card_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/project_group_dialog_theme_data.dart';
import 'package:metrics/common/presentation/button/theme/style/metrics_button_style.dart';

/// Stores the theme data for light metrics theme.
class LightMetricsThemeData extends MetricsThemeData {
  /// The default [TextStyle] for [TextField]s within the application.
  static const _defaultTextFieldTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16.0,
  );

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
          projectGroupCardTheme: const ProjectGroupCardThemeData(
            borderColor: ColorConfig.darkBorderColor,
            hoverColor: ColorConfig.darkCardHoverColor,
            backgroundColor: ColorConfig.lightScaffoldColor,
            accentColor: ColorConfig.accentColor,
            primaryColor: ColorConfig.primaryColor,
            titleStyle: TextStyle(
              color: Colors.black,
              height: 1.09,
              fontSize: 22.0,
              fontWeight: FontWeight.w500,
            ),
            subtitleStyle: TextStyle(
              color: ColorConfig.darkSecondaryTextColor,
              height: 1.23,
              fontSize: 13.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          addProjectGroupCardTheme: const ProjectGroupCardThemeData(
            primaryColor: ColorConfig.primaryColor,
            backgroundColor: ColorConfig.primaryTranslucentColor,
            titleStyle: TextStyle(
              color: ColorConfig.primaryColor,
              height: 1.5,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          projectGroupDialogTheme: const ProjectGroupDialogThemeData(
            accentColor: ColorConfig.accentColor,
            primaryColor: ColorConfig.primaryColor,
            backgroundColor: ColorConfig.lightScaffoldColor,
            closeIconColor: Colors.black,
            contentBorderColor: ColorConfig.darkBorderColor,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 26.0,
              fontWeight: FontWeight.w500,
            ),
            groupNameTextStyle: _defaultTextFieldTextStyle,
            searchForProjectTextStyle: _defaultTextFieldTextStyle,
            uncheckedProjectTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
            ),
            checkedProjectTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            counterTextStyle: TextStyleConfig.captionTextStyle,
            actionsTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
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
          metricsButtonTheme: const MetricsButtonThemeData(
            buttonAttentionLevel: MetricsButtonAttentionLevel(
              positive: MetricsButtonStyle(
                color: ColorConfig.primaryColor,
                labelColor: Colors.black,
                labelStyle: TextStyleConfig.buttonLabelStyle,
              ),
              neutral: MetricsButtonStyle(
                color: ColorConfig.inactiveColor,
                labelColor: Colors.white,
                labelStyle: TextStyleConfig.buttonLabelStyle,
              ),
              negative: MetricsButtonStyle(
                color: ColorConfig.accentColor,
                labelColor: Colors.black,
                labelStyle: TextStyleConfig.buttonLabelStyle,
              ),
              inactive: MetricsButtonStyle(
                color: ColorConfig.inactiveColor,
                labelColor: ColorConfig.inactiveTextColor,
                labelStyle: TextStyleConfig.buttonLabelStyle,
              ),
            ),
          ),
        );
}
