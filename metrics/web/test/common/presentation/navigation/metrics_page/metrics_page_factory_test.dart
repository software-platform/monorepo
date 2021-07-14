// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:metrics/auth/presentation/pages/login_page.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page_factory.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_configuration.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_name.dart';
import 'package:metrics/common/presentation/pages/loading_page.dart';
import 'package:metrics/dashboard/presentation/models/dashboard_page_parameters_model.dart';
import 'package:metrics/dashboard/presentation/pages/dashboard_page.dart';
import 'package:metrics/debug_menu/presentation/pages/debug_menu_page.dart';
import 'package:metrics/project_groups/presentation/pages/project_group_page.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../../test_utils/route_configuration_mock.dart';
import '../../../../test_utils/route_name_mock.dart';

void main() {
  group("MetricsPageFactory", () {
    const unknownRouteName = 'unknown';
    const pageParameters = DashboardPageParametersModel();
    const dashboardRouteName = RouteName.dashboard;
    const projectGroupsRouteName = RouteName.projectGroups;

    final metricsPageFactory = MetricsPageFactory();
    final routeName = RouteNameMock();
    final routeConfiguration = RouteConfigurationMock();

    tearDown(() {
      reset(routeConfiguration);
      reset(routeName);
    });

    test(
      ".create() returns the metrics page with the dashboard page child if the given route configuration is null",
      () {
        final page = metricsPageFactory.create(null, pageParameters);

        expect(page.child, isA<DashboardPage>());
      },
    );

    test(
      ".create() returns the metrics page with the name equals to the route configuration dashboard path if the given route configuration is null",
      () {
        final page = metricsPageFactory.create(null, pageParameters);

        expect(page.name, equals(RouteConfiguration.dashboard().path));
      },
    );

    test(
      ".create() returns the metrics page with the route name equals to the dashboard route name if the given route configuration is null",
      () {
        final page = metricsPageFactory.create(null, pageParameters);

        expect(page.routeName, equals(dashboardRouteName));
      },
    );

    test(
      ".create() returns the metrics page with the arguments equals to the given page parameters if the given route configuration is null",
      () {
        final page = metricsPageFactory.create(null, pageParameters);

        expect(page.arguments, equals(pageParameters));
      },
    );

    test(
      ".create() returns the metrics page with the dashboard page child if the given route configuration name is unknown",
      () {
        when(routeConfiguration.name).thenReturn(routeName);
        when(routeName.value).thenReturn(unknownRouteName);

        final page = metricsPageFactory.create(routeConfiguration, null);

        expect(page.child, isA<DashboardPage>());
      },
    );

    test(
      ".create() returns the metrics page with a name equals to the route configuration dashboard path if the given route configuration name is unknown",
      () {
        when(routeConfiguration.name).thenReturn(routeName);
        when(routeName.value).thenReturn(unknownRouteName);

        final page = metricsPageFactory.create(routeConfiguration, null);

        expect(page.name, equals(RouteConfiguration.dashboard().path));
      },
    );

    test(
      ".create() returns the metrics page with the route name equals to the dashboard route name if the given route configuration name is unknown",
      () {
        when(routeConfiguration.name).thenReturn(routeName);
        when(routeName.value).thenReturn(unknownRouteName);

        final page = metricsPageFactory.create(routeConfiguration, null);

        expect(page.routeName, equals(dashboardRouteName));
      },
    );

    test(
      ".create() returns the metrics page with the arguments equals to the given page parameters if the given route configuration name is unknown",
      () {
        when(routeConfiguration.name).thenReturn(routeName);
        when(routeName.value).thenReturn(unknownRouteName);

        final page = metricsPageFactory.create(
          routeConfiguration,
          pageParameters,
        );

        expect(page.arguments, equals(pageParameters));
      },
    );

    test(
      ".create() returns the metrics page with the dashboard page child if the given route configuration name is a dashboard",
      () {
        when(routeConfiguration.name).thenReturn(dashboardRouteName);

        final page = metricsPageFactory.create(routeConfiguration, null);

        expect(page.child, isA<DashboardPage>());
      },
    );

    test(
      ".create() returns the metrics page with the loading page child if the given route configuration name is a loading",
      () {
        when(routeConfiguration.name).thenReturn(RouteName.loading);

        final page = metricsPageFactory.create(routeConfiguration, null);

        expect(page.child, isA<LoadingPage>());
      },
    );

    test(
      ".create() returns the metrics page with the login page child if the given route configuration name is a login",
      () {
        when(routeConfiguration.name).thenReturn(RouteName.login);

        final page = metricsPageFactory.create(routeConfiguration, null);

        expect(page.child, isA<LoginPage>());
      },
    );

    test(
      ".create() returns the metrics page with the project groups page child if the given route configuration name is project groups",
      () {
        when(routeConfiguration.name).thenReturn(projectGroupsRouteName);

        final page = metricsPageFactory.create(routeConfiguration, null);

        expect(page.child, isA<ProjectGroupPage>());
      },
    );

    test(
      ".create() returns the metrics page with the debug menu page child if the given route configuration name is a debug menu",
      () {
        when(routeConfiguration.name).thenReturn(RouteName.debugMenu);

        final page = metricsPageFactory.create(routeConfiguration, null);

        expect(page.child, isA<DebugMenuPage>());
      },
    );

    test(
      ".create() returns the metrics page with the route name equals to the given route configuration route name",
      () {
        when(routeConfiguration.name).thenReturn(projectGroupsRouteName);

        final page = metricsPageFactory.create(routeConfiguration, null);

        expect(page.routeName, equals(projectGroupsRouteName));
      },
    );

    test(
      ".create() returns the metrics page with the name equals to the given route configuration path",
      () {
        when(routeConfiguration.name).thenReturn(projectGroupsRouteName);
        when(routeConfiguration.path)
            .thenReturn(RouteConfiguration.debugMenu().path);

        final page = metricsPageFactory.create(routeConfiguration, null);

        expect(page.name, equals(RouteConfiguration.debugMenu().path));
      },
    );

    test(
      ".create() returns the metrics page with the arguments equals to the given the given page parameters",
      () {
        when(routeConfiguration.name).thenReturn(projectGroupsRouteName);

        final page = metricsPageFactory.create(
          routeConfiguration,
          pageParameters,
        );

        expect(page.arguments, equals(pageParameters));
      },
    );
  });
}
