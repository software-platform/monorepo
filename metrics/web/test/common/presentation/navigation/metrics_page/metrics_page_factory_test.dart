// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:metrics/auth/presentation/pages/login_page.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page_factory.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_name.dart';
import 'package:metrics/common/presentation/pages/loading_page.dart';
import 'package:metrics/dashboard/presentation/models/dashboard_page_parameters_model.dart';
import 'package:metrics/dashboard/presentation/pages/dashboard_page.dart';
import 'package:metrics/debug_menu/presentation/pages/debug_menu_page.dart';
import 'package:metrics/project_groups/presentation/pages/project_group_page.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../../test_utils/route_name_mock.dart';

void main() {
  group("MetricsPageFactory", () {
    const unknownRouteName = 'unknown';
    const pageParameters = DashboardPageParametersModel();
    const dashboardRouteName = RouteName.dashboard;
    const loadingRouteName = RouteName.loading;
    const loginRouteName = RouteName.login;
    const projectGroupsRouteName = RouteName.projectGroups;
    const debugMenuRouteName = RouteName.debugMenu;

    final metricsPageFactory = MetricsPageFactory();
    final routeName = RouteNameMock();

    tearDown(() {
      reset(routeName);
    });

    test(
      ".create() returns the dashboard metrics page if the given route name is null",
      () {
        final page = metricsPageFactory.create(null, pageParameters);

        expect(page.child, isA<DashboardPage>());
      },
    );

    test(
      ".create() returns the dashboard metrics page with the name equals to the dashbord route name value if the given route name is null",
      () {
        final page = metricsPageFactory.create(null, pageParameters);

        expect(page.name, dashboardRouteName.value);
      },
    );

    test(
      ".create() returns the dashboard metrics page with arguments equals to the given page parameters if the route name is null",
      () {
        final page = metricsPageFactory.create(null, pageParameters);

        expect(page.arguments, equals(pageParameters));
      },
    );

    test(
      ".create() returns the dashboard metrics page if the given route name is unknown",
      () {
        when(routeName.value).thenReturn(unknownRouteName);

        final page = metricsPageFactory.create(routeName, null);

        expect(page.child, isA<DashboardPage>());
      },
    );

    test(
      ".create() returns the dashboard metrics page with a name equals to the given route name value if the route name is unknown",
      () {
        when(routeName.value).thenReturn(unknownRouteName);

        final page = metricsPageFactory.create(routeName, null);

        expect(page.name, equals(dashboardRouteName.value));
      },
    );

    test(
      ".create() returns the dashboard metrics page with arguments equals to the given page parameters if the route name is unknown",
      () {
        when(routeName.value).thenReturn(unknownRouteName);

        final page = metricsPageFactory.create(routeName, pageParameters);

        expect(page.arguments, equals(pageParameters));
      },
    );

    test(
      ".create() returns the dashboard metrics page if the given route name is a dashboard",
      () {
        final page = metricsPageFactory.create(dashboardRouteName, null);

        expect(page.child, isA<DashboardPage>());
      },
    );

    test(
      ".create() returns the dashboard metrics page with a name equals to the given route name value",
      () {
        final page = metricsPageFactory.create(dashboardRouteName, null);

        expect(page.name, equals(dashboardRouteName.value));
      },
    );

    test(
      ".create() returns the dashboard metrics page with arguments equals to the given page parameters",
      () {
        final page = metricsPageFactory.create(
          dashboardRouteName,
          pageParameters,
        );

        expect(page.arguments, equals(pageParameters));
      },
    );

    test(
      ".create() returns the loading metrics page if the given route name is a loading",
      () {
        final page = metricsPageFactory.create(loadingRouteName, null);

        expect(page.child, isA<LoadingPage>());
      },
    );

    test(
      ".create() returns the loading metrics page with a name equals to the given route name value",
      () {
        final page = metricsPageFactory.create(loadingRouteName, null);

        expect(page.name, equals(loadingRouteName.value));
      },
    );

    test(
      ".create() returns the loading metrics page with arguments equals to the given page parameters",
      () {
        final page = metricsPageFactory.create(
          loadingRouteName,
          pageParameters,
        );

        expect(page.arguments, equals(pageParameters));
      },
    );

    test(
      ".create() returns the login metrics page if the given route name is a login",
      () {
        final page = metricsPageFactory.create(loginRouteName, null);

        expect(page.child, isA<LoginPage>());
      },
    );

    test(
      ".create() returns the login metrics page with a name equals to the given route name value",
      () {
        final page = metricsPageFactory.create(loginRouteName, null);

        expect(page.name, equals(loginRouteName.value));
      },
    );

    test(
      ".create() returns the login metrics page with arguments equals to the given page parameters",
      () {
        final page = metricsPageFactory.create(loginRouteName, pageParameters);

        expect(page.arguments, equals(pageParameters));
      },
    );

    test(
      ".create() returns the project group metrics page if the given route name is project groups",
      () {
        final page = metricsPageFactory.create(projectGroupsRouteName, null);

        expect(page.child, isA<ProjectGroupPage>());
      },
    );

    test(
      ".create() returns the project groups metrics page with a name equals to the given route name value",
      () {
        final page = metricsPageFactory.create(projectGroupsRouteName, null);

        expect(page.name, equals(projectGroupsRouteName.value));
      },
    );

    test(
      ".create() returns the project groups metrics page with arguments equals to the given page parameters",
      () {
        final page = metricsPageFactory.create(
          projectGroupsRouteName,
          pageParameters,
        );

        expect(page.arguments, equals(pageParameters));
      },
    );

    test(
      ".create() returns the debug menu metrics page if the given route name is a debug menu",
      () {
        final page = metricsPageFactory.create(debugMenuRouteName, null);

        expect(page.child, isA<DebugMenuPage>());
      },
    );

    test(
      ".create() returns the debug menu metrics page with a name equals to the given route name value",
      () {
        final page = metricsPageFactory.create(debugMenuRouteName, null);

        expect(page.name, equals(debugMenuRouteName.value));
      },
    );

    test(
      ".create() returns the debug menu metrics page with arguments equals to the given page parameters",
      () {
        final page = metricsPageFactory.create(
          debugMenuRouteName,
          pageParameters,
        );

        expect(page.arguments, equals(pageParameters));
      },
    );
  });
}
