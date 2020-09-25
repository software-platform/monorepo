import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/base/presentation/widgets/keyboard_shortcuts.dart';
import 'package:metrics/common/presentation/widgets/metrics_fps_monitor.dart';
import 'package:statsfl/statsfl.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  group("MetricsFPSMonitor", () {
    testWidgets(
      "throws an AssertionError if the given child is null",
      (tester) async {
        await tester.pumpWidget(
          const _MetricsFPSMonitorTestbed(child: null),
        );

        expect(tester.takeException(), isAssertionError);
      },
    );

    testWidgets("displays the given child", (tester) async {
      const child = Text('child');

      await tester.pumpWidget(
        const _MetricsFPSMonitorTestbed(child: child),
      );

      expect(find.byWidget(child), findsOneWidget);
    });

    testWidgets(
      "displays the disabled FPS monitor by default",
      (tester) async {
        await tester.pumpWidget(const _MetricsFPSMonitorTestbed());

        final statsFlWidget = tester.widget<StatsFl>(find.byType(StatsFl));

        expect(statsFlWidget.isEnabled, isFalse);
      },
    );

    testWidgets(
      "applies the given keys to press",
      (WidgetTester tester) async {
        final keysToPress = LogicalKeySet(
          LogicalKeyboardKey.alt,
          LogicalKeyboardKey.keyF,
        );

        await tester.pumpWidget(
          const _MetricsFPSMonitorTestbed(),
        );

        final keyboardShortcutsWidget =
            tester.widget<KeyboardShortcuts>(find.byType(KeyboardShortcuts));

        expect(keyboardShortcutsWidget.keysToPress, equals(keysToPress));
      },
    );
  });
}

/// A testbed class needed to test the [MetricsFPSMonitor] widget.
class _MetricsFPSMonitorTestbed extends StatelessWidget {
  /// A default child widget used in tests.
  static const Widget _defaultChild = Text('default text');

  /// A widget to display.
  final Widget child;

  /// Creates a new instance of the metrics FPS monitor testbed.
  ///
  /// The [child] defaults to [_defaultChild].
  const _MetricsFPSMonitorTestbed({
    Key key,
    this.child = _defaultChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MetricsFPSMonitor(
          child: child,
        ),
      ),
    );
  }
}
