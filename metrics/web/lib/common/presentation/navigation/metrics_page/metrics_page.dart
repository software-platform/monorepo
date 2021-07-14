// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/navigation/metrics_page/metrics_page_route.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_name.dart';

/// A class that represents a Metrics application page.
class MetricsPage<T> extends Page<T> {
  /// A [Widget] to display as a content of this page.
  final Widget child;

  /// A [RouteName] of this page.
  final RouteName routeName;

  /// A flag that indicates whether this page should remain in memory
  /// when it is inactive.
  final bool maintainState;

  /// A flag that indicates whether this page is a full-screen dialog.
  final bool fullscreenDialog;

  /// Creates a new instance of the [MetricsPage].
  ///
  /// The [maintainState] defaults to `true`.
  /// The [fullscreenDialog] defaults to `false`.
  ///
  /// The [child], [routeName], [fullscreenDialog], and [maintainState] must not be null.
  const MetricsPage({
    @required this.child,
    @required this.routeName,
    this.maintainState = true,
    this.fullscreenDialog = false,
    LocalKey key,
    String name,
    Object arguments,
  })  : assert(child != null),
        assert(routeName != null),
        assert(maintainState != null),
        assert(fullscreenDialog != null),
        super(key: key, name:name, arguments: arguments);

  @override
  Route<T> createRoute(BuildContext context) {
    return MetricsPageRoute<T>(
      settings: this,
      builder: (_) => child,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }

  @override
  bool canUpdate(Page other) {
    bool canUpdate = true;

    if (other is MetricsPage) {
      canUpdate = other.name == name &&
          other.child == child &&
          other.fullscreenDialog == fullscreenDialog &&
          other.maintainState == maintainState;
    }

    return canUpdate && super.canUpdate(other);
  }

  @override
  MetricsPage<T> copyWith({String name, Object arguments}) {
    return MetricsPage(
      name: name ?? this.name,
      child: child,
      routeName: routeName,
      arguments: arguments ?? this.arguments,
    );
  }
}
