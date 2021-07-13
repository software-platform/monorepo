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
    const dashboardRouteName = RouteName.dashboard;
    const pageParametersModel = DashboardPageParametersModel();

    final metricsPageFactory = MetricsPageFactory();
    final routeName = RouteNameMock();

    tearDown(() {
      reset(routeName);
    });

    test(
      ".create() returns the dashboard metrics page if the given route name is null",
      () {
        final page = metricsPageFactory.create(null, pageParametersModel);

        expect(page.child, isA<DashboardPage>());
      },
    );

    test(
      ".create() returns the dashboard metrics page with the name equals to the dashbord route name value if the given route name is null",
      () {
        final page = metricsPageFactory.create(null, pageParametersModel);

        expect(page.name, dashboardRouteName.value);
      },
    );

    test(
      ".create() returns the loading metrics page with a name equals to the given route name value",
      () {
        const routeName = RouteName.loading;

        final actualName = metricsPageFactory.create(routeName, null).name;

        expect(actualName, equals(routeName.value));
      },
    );

    test(
      ".create() returns the loading metrics page with arguments equals to the given page parameters",
      () {
        final page = metricsPageFactory.create(
          RouteName.loading,
          pageParametersModel,
        );

        final actualArguments = page.arguments;

        expect(actualArguments, equals(pageParametersModel));
      },
    );

    test(
      ".create() returns the login metrics page with a name equals to the given route name value",
      () {
        const routeName = RouteName.login;

        final actualName = metricsPageFactory.create(routeName, null).name;

        expect(actualName, equals(routeName.value));
      },
    );

    test(
      ".create() returns the login metrics page with arguments equals to the given page parameters",
      () {
        final page = metricsPageFactory.create(
          RouteName.login,
          pageParametersModel,
        );

        final actualArguments = page.arguments;

        expect(actualArguments, equals(pageParametersModel));
      },
    );

    test(
      ".create() returns the dashboard metrics page with a name equals to the given route name value",
      () {
        final actualName =
            metricsPageFactory.create(dashboardRouteName, null).name;

        expect(actualName, equals(dashboardRouteName.value));
      },
    );

    test(
      ".create() returns the dashboard metrics page with arguments equals to the given page parameters",
      () {
        final page = metricsPageFactory.create(
          dashboardRouteName,
          pageParametersModel,
        );

        final actualArguments = page.arguments;

        expect(actualArguments, equals(pageParametersModel));
      },
    );

    test(
      ".create() returns the project groups metrics page with a name equals to the given route name value",
      () {
        const routeName = RouteName.projectGroups;

        final actualName = metricsPageFactory.create(routeName, null).name;

        expect(actualName, equals(routeName.value));
      },
    );

    test(
      ".create() returns the project groups metrics page with arguments equals to the given page parameters",
      () {
        final page = metricsPageFactory.create(
          RouteName.projectGroups,
          pageParametersModel,
        );

        final actualArguments = page.arguments;

        expect(actualArguments, equals(pageParametersModel));
      },
    );

    test(
      ".create() returns the debug menu metrics page with a name equals to the given route name value",
      () {
        const routeName = RouteName.debugMenu;

        final actualName = metricsPageFactory.create(routeName, null).name;

        expect(actualName, equals(routeName.value));
      },
    );

    test(
      ".create() returns the debug menu metrics page with arguments equals to the given page parameters",
      () {
        final page = metricsPageFactory.create(
          RouteName.debugMenu,
          pageParametersModel,
        );

        final actualArguments = page.arguments;

        expect(actualArguments, equals(pageParametersModel));
      },
    );

    test(
      ".create() returns the dashboard metrics page with a name equals to the given route name value if the route name is unknown",
      () {
        when(routeName.value).thenReturn(unknownRouteName);

        final actualName = metricsPageFactory.create(routeName, null).name;

        expect(actualName, equals(dashboardRouteName.value));
      },
    );

    test(
      ".create() returns the dashboard metrics page with arguments equals to the given page parameters if the route name is unknown",
      () {
        when(routeName.value).thenReturn(unknownRouteName);

        final page = metricsPageFactory.create(
          routeName,
          pageParametersModel,
        );

        final actualArguments = page.arguments;

        expect(actualArguments, equals(pageParametersModel));
      },
    );

    test(
      ".create() returns the loading metrics page if the given route name is a loading",
      () {
        final page = metricsPageFactory.create(RouteName.loading, null);

        expect(page.child, isA<LoadingPage>());
      },
    );

    test(
      ".create() returns the login metrics page if the given route name is a login",
      () {
        final page = metricsPageFactory.create(RouteName.login, null);

        expect(page.child, isA<LoginPage>());
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
      ".create() returns the project group metrics page if the given route name is project groups",
      () {
        final page = metricsPageFactory.create(RouteName.projectGroups, null);

        expect(page.child, isA<ProjectGroupPage>());
      },
    );

    test(
      ".create() returns the debug menu metrics page if the given route name is a debug menu",
      () {
        final page = metricsPageFactory.create(RouteName.debugMenu, null);

        expect(page.child, isA<DebugMenuPage>());
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
  });
}
