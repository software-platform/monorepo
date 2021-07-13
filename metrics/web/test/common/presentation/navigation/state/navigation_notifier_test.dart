// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:metrics/common/presentation/navigation/constants/default_routes.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page_factory.dart';
import 'package:metrics/common/presentation/navigation/models/factory/page_parameters_factory.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_configuration.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_name.dart';
import 'package:metrics/common/presentation/navigation/state/navigation_notifier.dart';
import 'package:metrics/common/presentation/pages/loading_page.dart';
import 'package:metrics/dashboard/presentation/models/dashboard_page_parameters_model.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../../test_utils/matchers.dart';
import '../../../../test_utils/navigation_state_mock.dart';

void main() {
  group("NavigationNotifier", () {
    const pageParametersModel = DashboardPageParametersModel(
      projectGroupId: 'projectGroupId',
      projectFilter: 'projectFilter',
    );
    final pageFactory = MetricsPageFactory();
    final navigationState = NavigationStateMock();
    final pageParametersFactory = _PageParametersFactoryMock();

    final parameters = pageParametersModel.toMap();
    final routeConfiguration = RouteConfiguration.dashboard(
      parameters: parameters,
    );

    NavigationNotifier notifier;

    void prepareNotifier() {
      notifier.handleAppInitialized(isAppInitialized: true);

      notifier.handleAuthenticationUpdates(isLoggedIn: false);
    }

    setUp(() {
      notifier = NavigationNotifier(
        pageFactory,
        pageParametersFactory,
        navigationState,
      );
      prepareNotifier();
      reset(pageParametersFactory);
    });

    final isLoginPageName = equals(DefaultRoutes.login.name.value);
    final isDashboardPageName = equals(DefaultRoutes.dashboard.name.value);
    final isProjectGroupsPageName = equals(
      DefaultRoutes.projectGroups.name.value,
    );
    final isLoadingPageName = equals(DefaultRoutes.loading.name.value);

    test(
      "throws an AssertionError if the given page factory is null",
      () {
        expect(
          () => NavigationNotifier(
            null,
            pageParametersFactory,
            navigationState,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      "throws an AssertionError if the given page parameters factory is null",
      () {
        expect(
          () => NavigationNotifier(
            pageFactory,
            null,
            navigationState,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      "throws an AssertionError if the given navigation state is null",
      () {
        expect(
          () => NavigationNotifier(pageFactory, pageParametersFactory, null),
          throwsAssertionError,
        );
      },
    );

    test(
      "creates an instance with the given parameters",
      () {
        expect(
          () => NavigationNotifier(
            pageFactory,
            pageParametersFactory,
            navigationState,
          ),
          returnsNormally,
        );
      },
    );

    test(
      ".pages is an unmodifiable list view",
      () {
        expect(notifier.pages, isA<UnmodifiableListView>());
      },
    );

    test(
      ".handleAuthenticationUpdates() clears pages and pushes to the login page when the user logs out",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);
        notifier.push(DefaultRoutes.dashboard);

        notifier.handleAuthenticationUpdates(isLoggedIn: false);

        final pages = notifier.pages;
        final currentPage = pages.last;

        expect(pages, hasLength(1));
        expect(currentPage.name, isLoginPageName);
      },
    );

    test(
      ".handleAppInitialized() throws an argument error if the given is app initialized is null",
      () {
        expect(
          () => notifier.handleAppInitialized(isAppInitialized: null),
          throwsArgumentError,
        );
      },
    );

    test(
      ".handleAppInitialized() redirects to the dashboard page when the app is initialized and the redirect route is loading page",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.handleInitialRoutePath(DefaultRoutes.loading);

        notifier.handleAppInitialized(isAppInitialized: true);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isDashboardPageName);
      },
    );

    test(
      ".handleAppInitialized() redirects to the dashboard page when the app is initialized and the redirect route is null",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.handleAppInitialized(isAppInitialized: true);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isDashboardPageName);
      },
    );

    test(
      ".handleAppInitialized() redirects to the redirect route when the app is initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.handleInitialRoutePath(DefaultRoutes.projectGroups);

        notifier.handleAppInitialized(isAppInitialized: true);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isProjectGroupsPageName);
      },
    );

    test(
      ".handleAppInitialized() clears the redirect route after redirect",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.handleInitialRoutePath(DefaultRoutes.projectGroups);

        notifier.handleAppInitialized(isAppInitialized: true);
        notifier.handleAppInitialized(isAppInitialized: true);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isDashboardPageName);
      },
    );

    test(
      ".handleAppInitialized() clears pages before redirect",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.handleInitialRoutePath(DefaultRoutes.loading);
        notifier.push(DefaultRoutes.dashboard);

        notifier.handleAppInitialized(isAppInitialized: true);

        final pages = notifier.pages;

        expect(pages, hasLength(equals(1)));
      },
    );

    test(
      ".pop() does nothing if pages are empty",
      () {
        final expectedPages = notifier.pages;

        notifier.pop();

        final actualPages = notifier.pages;

        expect(actualPages, equals(expectedPages));
      },
    );

    test(
      ".pop() does nothing if pages contain one page",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);
        notifier.push(DefaultRoutes.dashboard);

        final expectedPages = notifier.pages;

        notifier.pop();

        final actualPages = notifier.pages;

        expect(actualPages, equals(expectedPages));
      },
    );

    test(
      ".pop() removes the current page",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.push(DefaultRoutes.dashboard);
        notifier.push(DefaultRoutes.projectGroups);

        notifier.pop();

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isDashboardPageName);
      },
    );

    test(
      ".pop() sets the previous rote configuration to current configuration",
      () {
        final expectedConfiguration = DefaultRoutes.dashboard;
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.push(expectedConfiguration);
        notifier.push(DefaultRoutes.projectGroups);

        notifier.pop();

        expect(notifier.currentConfiguration, equals(expectedConfiguration));
      },
    );

    test(
      ".pop() updates the current page parameters",
      () {
        notifier.push(DefaultRoutes.projectGroups);

        final initialPageParameters = notifier.currentPageParameters;

        when(pageParametersFactory.create(any)).thenReturn(pageParametersModel);

        notifier.pop();

        expect(
          notifier.currentPageParameters,
          isNot(equals(initialPageParameters)),
        );
      },
    );

    test(
      ".pop() uses the given page parameters factory to create a page parameters",
      () {
        final currentConfiguration = notifier.currentConfiguration;

        notifier.push(DefaultRoutes.projectGroups);
        notifier.pop();

        verify(pageParametersFactory.create(currentConfiguration))
            .called(equals(2));
      },
    );

    test(
      ".push() pushes the loading page if the app is not initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);

        notifier.push(DefaultRoutes.dashboard);

        final currentPage = notifier.pages.last;

        expect(currentPage.child, isA<LoadingPage>());
      },
    );

    test(
      ".push() pushes the loading page with the given route name value as a name if the app is not initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);

        notifier.push(DefaultRoutes.dashboard);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, equals(RouteName.loading.value));
      },
    );

    test(
      ".push() pushes the given page if the user is logged in and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);
        notifier.push(DefaultRoutes.dashboard);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isDashboardPageName);
      },
    );

    test(
      ".push() pushes the login page if the user is not logged in, the given page requires authorization, and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: false);
        notifier.push(DefaultRoutes.dashboard);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isLoginPageName);
      },
    );

    test(
      ".push() pushes the given page if the user is not logged in, the given page does not require authorization, and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: false);
        notifier.push(DefaultRoutes.loading);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isLoadingPageName);
      },
    );

    test(
      ".push() updates the current configuration",
      () {
        final expectedConfiguration = DefaultRoutes.dashboard;
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.push(expectedConfiguration);

        expect(notifier.currentConfiguration, equals(expectedConfiguration));
      },
    );

    test(
      ".push() updates the current page parameters",
      () {
        final initialPageParameters = notifier.currentPageParameters;

        when(pageParametersFactory.create(any)).thenReturn(pageParametersModel);

        notifier.push(routeConfiguration);

        expect(
          notifier.currentPageParameters,
          isNot(equals(initialPageParameters)),
        );
      },
    );

    test(
      ".push() uses the given page parameters factory to create a page parameters",
      () {
        notifier.push(routeConfiguration);

        verify(pageParametersFactory.create(any)).called(once);
      },
    );

    test(
      ".pushReplacement() pushes the loading page if the app is not initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);

        notifier.pushReplacement(DefaultRoutes.dashboard);

        final currentPage = notifier.pages.last;

        expect(currentPage.child, isA<LoadingPage>());
      },
    );

    test(
      ".pushReplacement() pushes the loading page with the given route name value as a name if the app is not initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);
        notifier.pushReplacement(DefaultRoutes.dashboard);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, equals(RouteName.loading.value));
      },
    );

    test(
      ".pushReplacement() replaces the current page if pages are not empty",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);
        notifier.push(DefaultRoutes.dashboard);

        final expectedLength = notifier.pages.length;

        notifier.pushReplacement(DefaultRoutes.projectGroups);

        final actualLength = notifier.pages.length;

        expect(actualLength, equals(expectedLength));
      },
    );

    test(
      ".pushReplacement() adds the new page if pages are empty",
      () {
        final notifier = NavigationNotifier(
          pageFactory,
          pageParametersFactory,
          navigationState,
        );
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        final expectedLength = notifier.pages.length + 1;

        notifier.pushReplacement(DefaultRoutes.projectGroups);

        final actualLength = notifier.pages.length;

        expect(actualLength, equals(expectedLength));
      },
    );

    test(
      ".pushReplacement() replaces the current page with the given one if the user is logged in and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);
        notifier.push(DefaultRoutes.dashboard);

        notifier.pushReplacement(DefaultRoutes.projectGroups);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isProjectGroupsPageName);
      },
    );

    test(
      ".pushReplacement() replaces the current page with the login page if the user is not logged in, the given page requires authorization, and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: false);
        notifier.push(DefaultRoutes.loading);

        notifier.pushReplacement(DefaultRoutes.projectGroups);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isLoginPageName);
      },
    );

    test(
      ".pushReplacement() replaces the current page with the given page if the user is not logged in, the given page does not require authorization, and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: false);
        notifier.push(DefaultRoutes.loading);

        notifier.pushReplacement(DefaultRoutes.login);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isLoginPageName);
      },
    );

    test(
      ".pushReplacement() updates the current configuration",
      () {
        const expectedConfiguration = DefaultRoutes.loading;
        notifier.handleAuthenticationUpdates(isLoggedIn: false);
        notifier.push(DefaultRoutes.login);

        notifier.pushReplacement(expectedConfiguration);

        expect(notifier.currentConfiguration, equals(expectedConfiguration));
      },
    );

    test(
      ".pushStateReplacement() pushes the loading page if the app is not initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);

        notifier.pushStateReplacement(DefaultRoutes.dashboard);

        final currentPage = notifier.pages.last;

        expect(currentPage.child, isA<LoadingPage>());
      },
    );

    test(
      ".pushStateReplacement() pushes the loading page with the given route name value as a name if the app is not initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);
        notifier.pushStateReplacement(DefaultRoutes.dashboard);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, equals(DefaultRoutes.loading.name.value));
      },
    );

    test(
      ".pushStateReplacement() replaces the current page if pages are not empty",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);
        notifier.push(DefaultRoutes.dashboard);

        final expectedLength = notifier.pages.length;

        notifier.pushStateReplacement(DefaultRoutes.projectGroups);

        final actualLength = notifier.pages.length;

        expect(actualLength, equals(expectedLength));
      },
    );

    test(
      ".pushStateReplacement() adds the new page if pages are empty",
      () {
        final notifier = NavigationNotifier(
          pageFactory,
          pageParametersFactory,
          navigationState,
        );
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        final expectedLength = notifier.pages.length + 1;

        notifier.pushStateReplacement(DefaultRoutes.projectGroups);

        final actualLength = notifier.pages.length;

        expect(actualLength, equals(expectedLength));
      },
    );

    test(
      ".pushStateReplacement() replaces the current page with the given one if the user is logged in and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);
        notifier.push(DefaultRoutes.dashboard);

        notifier.pushStateReplacement(DefaultRoutes.projectGroups);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isProjectGroupsPageName);
      },
    );

    test(
      ".pushStateReplacement() replaces the current page with the login page if the user is not logged in, the given page requires authorization, and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: false);
        notifier.push(DefaultRoutes.loading);

        notifier.pushStateReplacement(DefaultRoutes.projectGroups);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isLoginPageName);
      },
    );

    test(
      ".pushStateReplacement() replaces the current page with the given page if the user is not logged in, the given page does not require authorization, and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: false);
        notifier.push(DefaultRoutes.loading);

        notifier.pushStateReplacement(DefaultRoutes.login);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isLoginPageName);
      },
    );

    test(
      ".pushStateReplacement() updates the current configuration",
      () {
        const expectedConfiguration = DefaultRoutes.loading;
        notifier.handleAuthenticationUpdates(isLoggedIn: false);
        notifier.push(DefaultRoutes.login);

        notifier.pushStateReplacement(expectedConfiguration);

        expect(notifier.currentConfiguration, equals(expectedConfiguration));
      },
    );

    test(
      ".pushStateReplacement() replaces the navigation state path with the pushed route configuration path",
      () {
        const expectedConfiguration = DefaultRoutes.loading;
        notifier.handleAuthenticationUpdates(isLoggedIn: false);
        notifier.push(DefaultRoutes.login);

        notifier.pushStateReplacement(expectedConfiguration);

        verify(navigationState.replaceState(
          any,
          any,
          notifier.currentConfiguration.path,
        ));
      },
    );

    test(
      ".pushAndRemoveUntil() pushes the loading page if the app is not initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);

        notifier.pushAndRemoveUntil(
          DefaultRoutes.dashboard,
          (page) => true,
        );

        final currentPage = notifier.pages.last;

        expect(currentPage.child, isA<LoadingPage>());
      },
    );

    test(
      ".pushAndRemoveUntil() pushes the loading page with the given route name value as a name if the app is not initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);
        notifier.pushAndRemoveUntil(DefaultRoutes.dashboard, (page) => true);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, equals(RouteName.loading.value));
      },
    );

    test(
      ".pushAndRemoveUntil() removes all underlying routes that don't satisfy the given predicate",
      () {
        final dashboardRouteName = DefaultRoutes.dashboard.name.value;

        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.push(DefaultRoutes.projectGroups);
        notifier.push(DefaultRoutes.login);
        notifier.push(DefaultRoutes.debugMenu);

        notifier.pushAndRemoveUntil(
          DefaultRoutes.dashboard,
          (page) => page.name == dashboardRouteName,
        );

        final pages = notifier.pages;

        final containsNotDashboard = pages.any(
          (page) => page.name != dashboardRouteName,
        );

        expect(containsNotDashboard, isFalse);
      },
    );

    test(
      ".pushAndRemoveUntil() does not remove the underlying routes after the predicate meets satisfying route",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.push(DefaultRoutes.projectGroups);
        notifier.push(DefaultRoutes.dashboard);
        notifier.push(DefaultRoutes.login);
        notifier.push(DefaultRoutes.debugMenu);

        notifier.pushAndRemoveUntil(
          DefaultRoutes.dashboard,
          (page) => page.name.contains(RouteName.dashboard.value),
        );

        final pages = notifier.pages;

        final containsProjectGroups = pages.any(
          (page) => page.name == DefaultRoutes.projectGroups.name.value,
        );

        expect(containsProjectGroups, isTrue);
      },
    );

    test(
      ".pushAndRemoveUntil() does not remove the route that satisfies predicate",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.push(DefaultRoutes.projectGroups);
        notifier.push(DefaultRoutes.dashboard);
        notifier.push(DefaultRoutes.login);
        notifier.push(DefaultRoutes.debugMenu);

        notifier.pushAndRemoveUntil(
          DefaultRoutes.dashboard,
          (page) => page.name.contains(RouteName.dashboard.value),
        );

        final pages = notifier.pages;

        final containsDashboardPage = pages.any(
          (page) => page.name == DefaultRoutes.dashboard.name.value,
        );

        expect(containsDashboardPage, isTrue);
      },
    );

    test(
      ".pushAndRemoveUntil() pushes the given page if the user is logged in and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);
        notifier.push(DefaultRoutes.projectGroups);

        notifier.pushAndRemoveUntil(
          DefaultRoutes.dashboard,
          (page) => true,
        );

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isDashboardPageName);
      },
    );

    test(
      ".pushAndRemoveUntil() pushes the login page if the user is not logged in, the given page requires authorization, and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: false);
        notifier.push(DefaultRoutes.loading);

        notifier.pushAndRemoveUntil(
          DefaultRoutes.dashboard,
          (page) => true,
        );

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isLoginPageName);
      },
    );

    test(
      ".pushAndRemoveUntil() pushes the given page if the user is not logged in, the given page does not require authorization, and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: false);
        notifier.push(DefaultRoutes.loading);

        notifier.pushAndRemoveUntil(
          DefaultRoutes.login,
          (page) => true,
        );

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isLoginPageName);
      },
    );

    test(
      ".pushAndRemoveUntil() updates the current configuration",
      () {
        final expectedConfiguration = DefaultRoutes.dashboard;
        notifier.handleAuthenticationUpdates(isLoggedIn: true);
        notifier.push(DefaultRoutes.projectGroups);

        notifier.pushAndRemoveUntil(
          expectedConfiguration,
          (page) => true,
        );

        expect(notifier.currentConfiguration, equals(expectedConfiguration));
      },
    );

    test(
      ".handleInitialRoutePath() pushes the loading page if the app is not initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);

        notifier.handleInitialRoutePath(DefaultRoutes.dashboard);

        final currentPage = notifier.pages.last;

        expect(currentPage.child, isA<LoadingPage>());
      },
    );

    test(
      ".handleInitialRoutePath() pushes the loading page with the given route name value as a name if the app is not initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);

        notifier.handleInitialRoutePath(DefaultRoutes.dashboard);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, equals(RouteName.loading.value));
      },
    );

    test(
      ".handleInitialRoutePath() pushes the given page if the user is logged in and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.handleInitialRoutePath(DefaultRoutes.projectGroups);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isProjectGroupsPageName);
      },
    );

    test(
      ".handleInitialRoutePath() pushes the login page if the user is not logged in, the given page requires authorization, and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: false);

        notifier.handleInitialRoutePath(DefaultRoutes.projectGroups);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isLoginPageName);
      },
    );

    test(
      ".handleInitialRoutePath() pushes the given page if the user is not logged in, the given page does not require authorization, and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: false);

        notifier.handleInitialRoutePath(DefaultRoutes.login);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isLoginPageName);
      },
    );

    test(
      ".handleInitialRoutePath() updates the current configuration",
      () {
        final expectedConfiguration = DefaultRoutes.projectGroups;

        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.handleInitialRoutePath(expectedConfiguration);

        expect(notifier.currentConfiguration, equals(expectedConfiguration));
      },
    );

    test(
      ".handleInitialRoutePath() updates the current page parameters",
      () {
        final initialPageParameters = notifier.currentPageParameters;

        when(pageParametersFactory.create(any)).thenReturn(pageParametersModel);

        notifier.handleInitialRoutePath(routeConfiguration);

        expect(
          notifier.currentPageParameters,
          isNot(equals(initialPageParameters)),
        );
      },
    );

    test(
      ".handleInitialRoutePath() uses the given page parameters factory to create a page parameters",
      () {
        notifier.handleInitialRoutePath(routeConfiguration);

        verify(pageParametersFactory.create(any)).called(once);
      },
    );

    test(
      ".handleNewRoutePath() pushes the loading page if the app is not initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);

        notifier.handleNewRoutePath(DefaultRoutes.dashboard);

        final currentPage = notifier.pages.last;

        expect(currentPage.child, isA<LoadingPage>());
      },
    );

    test(
      ".handleNewRoutePath() pushes the loading page with the given route name value as a name if the app is not initialized",
      () {
        notifier.handleAppInitialized(isAppInitialized: false);

        notifier.handleNewRoutePath(DefaultRoutes.dashboard);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, equals(RouteName.loading.value));
      },
    );

    test(
      ".handleNewRoutePath() pushes the given page if the user is logged in and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.handleNewRoutePath(DefaultRoutes.projectGroups);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isProjectGroupsPageName);
      },
    );

    test(
      ".handleNewRoutePath() pushes the login page if the user is not logged in, the given page requires authorization, and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: false);

        notifier.handleNewRoutePath(DefaultRoutes.projectGroups);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isLoginPageName);
      },
    );

    test(
      ".handleNewRoutePath() pushes the given page if the user is not logged in, the given page does not require authorization, and the app is initialized",
      () {
        notifier.handleAuthenticationUpdates(isLoggedIn: false);

        notifier.handleNewRoutePath(DefaultRoutes.login);

        final currentPage = notifier.pages.last;

        expect(currentPage.name, isLoginPageName);
      },
    );

    test(
      ".handleNewRoutePath() updates the current configuration",
      () {
        final expectedConfiguration = DefaultRoutes.projectGroups;

        notifier.handleAuthenticationUpdates(isLoggedIn: true);

        notifier.handleNewRoutePath(expectedConfiguration);

        expect(notifier.currentConfiguration, equals(expectedConfiguration));
      },
    );

    test(
      ".replaceState() delegates to the navigation state",
      () {
        const data = 'data';
        const title = 'title';
        const path = '/test';

        notifier.replaceState(data: data, title: title, path: path);

        verify(
          navigationState.replaceState(data, title, path),
        ).called(once);
      },
    );
  });
}

class _PageParametersFactoryMock extends Mock implements PageParametersFactory {}
