// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page_route.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_name.dart';
import 'package:metrics/dashboard/presentation/models/dashboard_page_parameters_model.dart';
import 'package:test/test.dart';

import '../../../../test_utils/matchers.dart';

void main() {
  group("MetricsPage", () {
    const child = Text('child');
    const routeName = RouteName.dashboard;
    const arguments = DashboardPageParametersModel();

    test(
      "throws an AssertionError if the given child is null",
      () {
        expect(
          () => MetricsPage(child: null, routeName: routeName),
          throwsAssertionError,
        );
      },
    );

    test(
      "throws an AssertionError if the given route name is null",
      () {
        expect(
          () => MetricsPage(child: child, routeName: null),
          throwsAssertionError,
        );
      },
    );

    test(
      "throws an AssertionError if the given maintain state is null",
      () {
        expect(
          () => MetricsPage(
            child: child,
            routeName: routeName,
            maintainState: null,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      "throws an AssertionError if the given fullscreen dialog is null",
      () {
        expect(
          () => MetricsPage(
            child: child,
            routeName: routeName,
            fullscreenDialog: null,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      "uses the default maintain state value if the given parameter is not specified",
      () {
        const metricsPage = MetricsPage(child: child, routeName: routeName);

        expect(metricsPage.maintainState, isNotNull);
      },
    );

    test(
      "uses the default fullscreen dialog value if the given parameter is not specified",
      () {
        const metricsPage = MetricsPage(child: child, routeName: routeName);

        expect(metricsPage.fullscreenDialog, isNotNull);
      },
    );

    test(
      ".createRoute() returns a metrics page route with the given arguments",
      () {
        const metricsPage = MetricsPage(
          child: child,
          routeName: routeName,
          arguments: arguments,
        );
        final actualRoute = metricsPage.createRoute(null);

        expect(actualRoute.settings.arguments, arguments);
      },
    );

    test(
      ".createRoute() returns a metrics page route with the given name",
      () {
        const name = 'test';
        const metricsPage = MetricsPage(
          child: child,
          routeName: routeName,
          name: name,
        );
        final actualRoute = metricsPage.createRoute(null);

        expect(actualRoute.settings.name, name);
      },
    );

    test(
      ".createRoute() returns the metrics page route that builds the given child widget",
      () {
        const metricsPage = MetricsPage(child: child, routeName: routeName);
        final actualRoute = metricsPage.createRoute(null) as MetricsPageRoute;
        final actualChild = actualRoute.builder(null);

        expect(actualChild, equals(child));
      },
    );

    test(
      ".copyWith() returns the same metrics page if called without params",
      () {
        const metricsPage = MetricsPage(
          child: child,
          routeName: routeName,
          arguments: arguments,
        );

        final updatedPage = metricsPage.copyWith();

        expect(metricsPage.child, equals(updatedPage.child));
        expect(metricsPage.arguments, equals(updatedPage.arguments));
        expect(metricsPage.routeName, equals(updatedPage.routeName));
        expect(metricsPage.name, equals(updatedPage.name));
      },
    );

    test(
      ".copyWith() creates a copy of an instance with arguments replaced with the new values",
      () {
        const metricsPage = MetricsPage(child: child, routeName: routeName);

        const name = 'test';
        final updatedPage = metricsPage.copyWith(
          name: name,
          arguments: arguments,
        );

        expect(updatedPage.name, equals(name));
        expect(updatedPage.arguments, equals(arguments));
      },
    );
  });
}
