// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:metrics/auth/presentation/pages/login_page.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page.dart';
import 'package:metrics/common/presentation/navigation/models/page_parameters_model.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_name.dart';
import 'package:metrics/common/presentation/pages/loading_page.dart';
import 'package:metrics/dashboard/presentation/pages/dashboard_page.dart';
import 'package:metrics/debug_menu/presentation/pages/debug_menu_page.dart';
import 'package:metrics/project_groups/presentation/pages/project_group_page.dart';

/// A factory that is responsible for creating the [MetricsPage]
/// depending on the [RouteName].
class MetricsPageFactory {
  /// Creates the [MetricsPage] using the given [routeName] and [pageParameters].
  ///
  /// If the given [routeName] is `null` or does not match to any of [RouteName]s
  /// returns the [DashboardPage].
  MetricsPage create(
    RouteName routeName,
    PageParametersModel pageParameters,
  ) {
    switch (routeName) {
      case RouteName.loading:
        return MetricsPage(
          child: const LoadingPage(),
          routeName: routeName,
          arguments: pageParameters,
          name: routeName.value,
        );
      case RouteName.login:
        return MetricsPage(
          child: const LoginPage(),
          routeName: routeName,
          arguments: pageParameters,
          name: routeName.value,
        );
      case RouteName.dashboard:
        return MetricsPage(
          child: DashboardPage(),
          routeName: routeName,
          arguments: pageParameters,
          name: routeName.value,
        );
      case RouteName.projectGroups:
        return MetricsPage(
          child: ProjectGroupPage(),
          routeName: routeName,
          arguments: pageParameters,
          name: routeName.value,
        );
      case RouteName.debugMenu:
        return MetricsPage(
          child: const DebugMenuPage(),
          routeName: routeName,
          arguments: pageParameters,
          name: routeName.value,
        );
    }

    return MetricsPage(
      child: DashboardPage(),
      routeName: RouteName.dashboard,
      arguments: pageParameters,
      name: RouteName.dashboard.value,
    );
  }
}
