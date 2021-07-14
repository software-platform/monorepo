// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:metrics/auth/presentation/pages/login_page.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page.dart';
import 'package:metrics/common/presentation/navigation/models/page_parameters_model.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_configuration.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_name.dart';
import 'package:metrics/common/presentation/pages/loading_page.dart';
import 'package:metrics/dashboard/presentation/pages/dashboard_page.dart';
import 'package:metrics/debug_menu/presentation/pages/debug_menu_page.dart';
import 'package:metrics/project_groups/presentation/pages/project_group_page.dart';

/// A factory that is responsible for creating the [MetricsPage]
/// depending on the [RouteName].
class MetricsPageFactory {
  /// Creates the [MetricsPage] using the given [routeConfiguration]
  /// and [pageParameters].
  ///
  /// If the given [routeConfiguration] is `null` or the [routeConfiguration]'s
  /// name does not match to any of [RouteName]s returns the [DashboardPage].
  MetricsPage create(
    RouteConfiguration routeConfiguration,
    PageParametersModel pageParameters,
  ) {
    Widget child = DashboardPage();
    RouteName routeName = RouteName.dashboard;
    String path = RouteConfiguration.dashboard().path;

    if (routeConfiguration == null) {
      return _createMetricsPage(child, routeName, path, pageParameters);
    }

    final routeConfigurationName = routeConfiguration.name;

    switch (routeConfigurationName) {
      case RouteName.loading:
        child = const LoadingPage();
        routeName = routeConfigurationName;
        path = routeConfiguration.path;
        break;
      case RouteName.login:
        child = const LoginPage();
        routeName = routeConfigurationName;
        path = routeConfiguration.path;
        break;
      case RouteName.dashboard:
        child = DashboardPage();
        routeName = routeConfigurationName;
        path = routeConfiguration.path;
        break;
      case RouteName.projectGroups:
        child = ProjectGroupPage();
        routeName = routeConfigurationName;
        path = routeConfiguration.path;
        break;
      case RouteName.debugMenu:
        child = const DebugMenuPage();
        routeName = routeConfigurationName;
        path = routeConfiguration.path;
        break;
    }

    return _createMetricsPage(child, routeName, path, pageParameters);
  }

  /// Creates a new instance of the [MetricsPage] with the given parameters.
  MetricsPage _createMetricsPage(
    Widget child,
    RouteName routeName,
    String path,
    PageParametersModel arguments,
  ) {
    return MetricsPage(
      name: path,
      child: child,
      routeName: routeName,
      arguments: arguments,
    );
  }
}
