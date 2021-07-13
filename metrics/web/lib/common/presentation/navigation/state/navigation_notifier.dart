// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/navigation/constants/default_routes.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page_factory.dart';
import 'package:metrics/common/presentation/navigation/models/factory/page_parameters_factory.dart';
import 'package:metrics/common/presentation/navigation/models/page_parameters_model.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_configuration.dart';
import 'package:metrics/common/presentation/navigation/state/navigation_state.dart';

/// A signature for the function that tests the given [MetricsPage] for certain
/// conditions.
typedef MetricsPagePredicate = bool Function(MetricsPage);

/// A [ChangeNotifier] that manages navigation.
class NavigationNotifier extends ChangeNotifier {
  /// A [NavigationState] used to interact with the current navigation state.
  final NavigationState _navigationState;

  /// A [MetricsPageFactory] that provides an ability to create a [MetricsPage]
  /// from [RouteConfiguration].
  final MetricsPageFactory _pageFactory;

  /// A [PageParametersFactory] used to create a [PageParametersModel] 
  /// from the [RouteConfiguration].
  final PageParametersFactory _pageParametersFactory;

  /// A stack of [MetricsPage]s to use by navigator.
  final List<MetricsPage> _pages = [];

  /// A [RouteConfiguration] that represents the current page route.
  RouteConfiguration _currentConfiguration;

  /// A [PageParametersModel] that represents current page parameters.
  PageParametersModel _currentPageParameters;

  /// A [RouteConfiguration] redirect to when the application finishes
  /// initialization.
  RouteConfiguration _redirectRoute;

  /// A flag that indicates whether the user is logged in.
  bool _isUserLoggedIn = false;

  /// A flag that indicates whether the application is finished loading.
  bool _isAppInitialized = false;

  /// Provides an [UnmodifiableListView] of [MetricsPage]s to use in navigation.
  UnmodifiableListView<MetricsPage> get pages => UnmodifiableListView(_pages);

  /// Provides a [RouteConfiguration] that describes the navigation state.
  RouteConfiguration get currentConfiguration => _currentConfiguration;

  /// Provides a [PageParametersModel] that describes the current page
  /// parameters.
  PageParametersModel get currentPageParameters => _currentPageParameters;

  /// Creates a new instance of the [NavigationNotifier]
  /// with the given [MetricsPageFactory].
  ///
  /// Throws an [AssertionError] if the given [MetricsPageFactory] is `null`.
  /// Throws an [AssertionError] if the given [PageParametersFactory] is `null`.
  NavigationNotifier(
    this._pageFactory,
    this._pageParametersFactory,
    NavigationState navigationState,
  )   : assert(_pageFactory != null),
        assert(_pageParametersFactory != null),
        assert(navigationState != null),
        _navigationState = navigationState;

  /// Handles the authentication update represented by the given [isLoggedIn].
  ///
  /// Clears the pages stack and pushes the [DefaultRoutes.login]
  /// after the user logs out.
  void handleAuthenticationUpdates({
    bool isLoggedIn,
  }) {
    if (_isUserLoggedIn == isLoggedIn) return;

    final currentPageName = currentConfiguration?.name;
    _isUserLoggedIn = isLoggedIn ?? false;

    if (!_isUserLoggedIn && currentPageName != DefaultRoutes.login.name) {
      _pages.clear();

      push(DefaultRoutes.login);
    }
  }

  /// Handles the application's initialization state update represented by the
  /// given [isAppInitialized].
  ///
  /// If the [isAppInitialized] is `true`, redirects to the redirect route.
  ///
  /// Throws an [ArgumentError] if the given [isAppInitialized] is `null`.
  void handleAppInitialized({
    @required bool isAppInitialized,
  }) {
    ArgumentError.checkNotNull(isAppInitialized, 'isAppInitialized');

    _isAppInitialized = isAppInitialized;

    if (_isAppInitialized) _redirect();
  }

  /// Removes the current page and navigates to the previous one.
  void pop() {
    if (_pages.length <= 1) return;

    _pages.removeLast();

    final currentPage = _pages.last;
    final newConfiguration = _getConfigurationFromPage(currentPage);

    _currentConfiguration = newConfiguration;

    _updatePageParameters();

    notifyListeners();
  }

  /// Pushes the route created from the given [configuration].
  void push(RouteConfiguration configuration) {
    _addNewPage(configuration);
    notifyListeners();
  }

  /// Replaces the current route with the route created from the given
  /// [configuration].
  void pushReplacement(RouteConfiguration configuration) {
    if (_pages.isNotEmpty) _pages.removeLast();

    push(configuration);
  }

  /// Replaces the current navigation state with the given parameters.
  void replaceState({
    dynamic data,
    String title = 'metrics',
    String path,
  }) {
    _navigationState.replaceState(data, title, path);
  }

  /// Removes all underlying pages until the [predicate] returns `true`
  /// or the stack of pages is empty and pushes the route created from the given
  /// [configuration].
  void pushAndRemoveUntil(
    RouteConfiguration configuration,
    MetricsPagePredicate predicate,
  ) {
    while (_pages.isNotEmpty) {
      final page = _pages.last;

      if (predicate(page)) break;

      _pages.removeLast();
    }

    push(configuration);
  }

  /// Replaces the current route with the route created from the given
  /// [configuration] and replaces the current state path with
  /// the path of the pushed route configuration.
  void pushStateReplacement(RouteConfiguration configuration) {
    if (_pages.isNotEmpty) _pages.removeLast();

    push(configuration);
    replaceState(
      path: _currentConfiguration.path,
    );
  }

  /// Handles the initial route.
  void handleInitialRoutePath(RouteConfiguration configuration) {
    _addNewPage(configuration);
  }

  /// Handles the new route.
  void handleNewRoutePath(RouteConfiguration configuration) {
    push(configuration);
  }

  /// Redirects to the redirect route and clears it.
  ///
  /// If the redirect route is [DefaultRoutes.loading] or `null`,
  /// redirects to the [DefaultRoutes.dashboard].
  void _redirect() {
    if (_redirectRoute == null || _redirectRoute == DefaultRoutes.loading) {
      _redirectRoute = DefaultRoutes.dashboard;
    }

    _pages.clear();
    push(_redirectRoute);
    _redirectRoute = null;
  }

  /// Creates a [RouteConfiguration] using the given [page].
  RouteConfiguration _getConfigurationFromPage(MetricsPage page) {
    final name = page?.name;

    return RouteConfiguration.values.firstWhere(
      (route) => route.name.value == name,
      orElse: () => DefaultRoutes.dashboard,
    );
  }

  /// Adds a new page created from the given [configuration] to the [pages].
  void _addNewPage(RouteConfiguration configuration) {
    final newConfiguration = _processConfiguration(configuration);

    _currentConfiguration = newConfiguration;

    final newPage = _pageFactory.create(
      _currentConfiguration.name,
      _currentPageParameters,
    );

    _updatePageParameters();

    _pages.add(newPage);
  }

  /// Processes the given [configuration] depending on [_isAppInitialized] state,
  /// [configuration]'s authorization requirements and current
  /// [_isUserLoggedIn] state.
  ///
  /// If the application is not initialized, returns [DefaultRoutes.loading]
  /// and saves the [_redirectRoute].
  ///
  /// If the user is not logged in and the given [configuration]
  /// requires authorization, returns [DefaultRoutes.login]
  ///
  /// Otherwise, returns [configuration].
  RouteConfiguration _processConfiguration(
    RouteConfiguration configuration,
  ) {
    if (!_isAppInitialized) {
      _redirectRoute = configuration;

      return DefaultRoutes.loading.copyWith(path: configuration.path);
    }

    final authorizationRequired = configuration.authorizationRequired;

    if (!_isUserLoggedIn && authorizationRequired) return DefaultRoutes.login;

    return configuration;
  }

  /// Updates the [_currentPageParameters] based on the [_currentConfiguration].
  void _updatePageParameters() {
    final pageParameters = _pageParametersFactory.create(_currentConfiguration);

    _currentPageParameters = pageParameters;
  }
}
