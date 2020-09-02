import 'package:flutter/material.dart';
import 'package:metrics/base/presentation/widgets/base_popup.dart';
import 'package:metrics/base/presentation/widgets/hand_cursor.dart';
import 'package:metrics/common/presentation/routes/observers/overlay_entry_route_observer.dart';
import 'package:metrics/common/presentation/strings/common_strings.dart';
import 'package:metrics/common/presentation/widgets/metrics_user_menu_card.dart';

/// A widget that displayed the user menu pop-up.
class MetricsUserMenu extends StatelessWidget {
  /// A width of the metrics user menu.
  static const double _maxWidth = 220.0;

  /// A right padding from the trigger widget.
  static const double _rightPadding = 3.0;

  /// A top padding from the trigger widget.
  static const double _topPadding = 3.0;

  /// Creates the [MetricsUserMenu].
  const MetricsUserMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final observers = Navigator.of(context).widget.observers;
    final overlayEntryRouteObserver = observers.firstWhere(
      (element) => element is OverlayEntryRouteObserver,
      orElse: () => null,
    ) as RouteObserver;

    return BasePopup(
      popupConstraints: const BoxConstraints(
        maxWidth: _maxWidth,
      ),
      offsetBuilder: (size) {
        return Offset(
          size.width - _maxWidth - _rightPadding,
          size.height + _topPadding,
        );
      },
      triggerBuilder: (context, openPopup, closePopup) {
        return Tooltip(
          message: CommonStrings.openUserMenu,
          child: HandCursor(
            child: InkWell(
              onTap: openPopup,
              customBorder: const CircleBorder(),
              child: Image.network(
                'icons/avatar.svg',
                width: 32.0,
                height: 32.0,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
      popup: const MetricsUserMenuCard(),
      routeObserver: overlayEntryRouteObserver,
    );
  }
}
