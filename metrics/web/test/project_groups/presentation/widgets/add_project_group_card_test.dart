import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/base/presentation/widgets/hand_cursor.dart';
import 'package:metrics/base/presentation/widgets/info_dialog.dart';
import 'package:metrics/base/presentation/widgets/padded_card.dart';
import 'package:metrics/common/presentation/metrics_theme/model/add_project_group_card/attention_level/add_project_group_card_attention_level.dart';
import 'package:metrics/common/presentation/metrics_theme/model/add_project_group_card/style/add_project_group_card_style.dart';
import 'package:metrics/common/presentation/metrics_theme/model/add_project_group_card/theme_data/add_project_group_card_theme_data.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metrics_theme_data.dart';
import 'package:metrics/project_groups/presentation/state/project_groups_notifier.dart';
import 'package:metrics/project_groups/presentation/strings/project_groups_strings.dart';
import 'package:metrics/project_groups/presentation/view_models/project_group_dialog_view_model.dart';
import 'package:metrics/project_groups/presentation/widgets/add_project_group_card.dart';
import 'package:metrics/project_groups/presentation/widgets/add_project_group_dialog.dart';
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../test_utils/finder_util.dart';
import '../../../test_utils/metrics_themed_testbed.dart';
import '../../../test_utils/project_groups_notifier_mock.dart';
import '../../../test_utils/test_injection_container.dart';

void main() {
  group("AddProjectGroupCard", () {
    const positiveBackgroundColor = Colors.red;
    const positiveLabelStyle = TextStyle(color: Colors.red);
    const positiveIconColor = Colors.red;
    const positiveHoverColor = Colors.red;

    const inactiveBackgroundColor = Colors.grey;
    const inactiveLabelStyle = TextStyle(color: Colors.grey);
    const inactiveIconColor = Colors.grey;
    const inactiveHoverColor = Colors.grey;

    const metricsTheme = MetricsThemeData(
      addProjectGroupCardTheme: AddProjectGroupCardThemeData(
        attentionLevel: AddProjectGroupCardAttentionLevel(
          positive: AddProjectGroupCardStyle(
            backgroundColor: positiveBackgroundColor,
            iconColor: positiveIconColor,
            hoverColor: positiveHoverColor,
            labelStyle: positiveLabelStyle,
          ),
          inactive: AddProjectGroupCardStyle(
            backgroundColor: inactiveBackgroundColor,
            iconColor: inactiveIconColor,
            hoverColor: inactiveHoverColor,
            labelStyle: inactiveLabelStyle,
          ),
        ),
      ),
    );

    testWidgets(
      "displays the padded card",
      (WidgetTester tester) async {
        await mockNetworkImagesFor(
          () => tester.pumpWidget(const _AddProjectGroupCardTestbed()),
        );

        expect(find.byType(PaddedCard), findsOneWidget);
      },
    );

    testWidgets(
      "applies a hand cursor to the card",
      (WidgetTester tester) async {
        await mockNetworkImagesFor(() {
          return tester.pumpWidget(const _AddProjectGroupCardTestbed());
        });

        final finder = find.byWidgetPredicate(
          (widget) => widget is PaddedCard && widget.child is HandCursor,
        );

        expect(finder, findsOneWidget);
      },
    );

    testWidgets(
      "applies the enabled background color from the theme to the enabled add project group",
      (WidgetTester tester) async {
        await mockNetworkImagesFor(
          () => tester.pumpWidget(
            const _AddProjectGroupCardTestbed(theme: metricsTheme),
          ),
        );

        final cardWidget = tester.widget<PaddedCard>(find.byType(PaddedCard));

        expect(cardWidget.backgroundColor, equals(positiveBackgroundColor));
      },
    );

    testWidgets(
      "applies the enabled text style from the theme to the enabled add project group text style",
      (WidgetTester tester) async {
        await mockNetworkImagesFor(
          () => tester.pumpWidget(
            const _AddProjectGroupCardTestbed(theme: metricsTheme),
          ),
        );

        final textWidget = tester.widget<Text>(
          find.text(ProjectGroupsStrings.createGroup),
        );

        expect(textWidget.style, equals(positiveLabelStyle));
      },
    );

    testWidgets(
      "applies the disabled background color from the theme when the add project group card is disabled",
      (WidgetTester tester) async {
        final notifierMock = ProjectGroupsNotifierMock();
        when(notifierMock.hasConfiguredProjects).thenReturn(false);

        await mockNetworkImagesFor(
          () => tester.pumpWidget(
            _AddProjectGroupCardTestbed(
              theme: metricsTheme,
              projectGroupsNotifier: notifierMock,
            ),
          ),
        );
        final cardWidget = tester.widget<PaddedCard>(find.byType(PaddedCard));

        expect(cardWidget.backgroundColor, equals(inactiveBackgroundColor));
      },
    );

    testWidgets(
      "applies the disabled text style from the theme when the add project group card is disabled",
      (WidgetTester tester) async {
        final notifierMock = ProjectGroupsNotifierMock();
        when(notifierMock.hasConfiguredProjects).thenReturn(false);

        await mockNetworkImagesFor(
          () => tester.pumpWidget(
            _AddProjectGroupCardTestbed(
              theme: metricsTheme,
              projectGroupsNotifier: notifierMock,
            ),
          ),
        );
        final textWidget = tester.widget<Text>(
          find.text(ProjectGroupsStrings.createGroup),
        );

        expect(textWidget.style, equals(inactiveLabelStyle));
      },
    );

    testWidgets(
      "shows the add project group dialog on tap",
      (WidgetTester tester) async {
        final notifierMock = ProjectGroupsNotifierMock();
        when(notifierMock.hasConfiguredProjects).thenReturn(true);
        when(notifierMock.projectGroupDialogViewModel).thenReturn(
          ProjectGroupDialogViewModel(
            selectedProjectIds: UnmodifiableListView([]),
          ),
        );

        await mockNetworkImagesFor(
          () => tester.pumpWidget(_AddProjectGroupCardTestbed(
            projectGroupsNotifier: notifierMock,
          )),
        );

        await tester.tap(find.byType(AddProjectGroupCard));
        await tester.pump();

        expect(find.byType(AddProjectGroupDialog), findsOneWidget);
      },
    );

    testWidgets(
      "does not open the add project group dialog if the card is disabled",
      (WidgetTester tester) async {
        final notifierMock = ProjectGroupsNotifierMock();
        when(notifierMock.hasConfiguredProjects).thenReturn(false);

        await mockNetworkImagesFor(
          () => tester.pumpWidget(_AddProjectGroupCardTestbed(
            projectGroupsNotifier: notifierMock,
          )),
        );

        await tester.tap(find.byType(AddProjectGroupCard));
        await tester.pump();

        expect(find.byType(AddProjectGroupDialog), findsNothing);
      },
    );

    testWidgets(
      "does not open the add project group dialog if the project group dialog view model is null",
      (WidgetTester tester) async {
        final notifierMock = ProjectGroupsNotifierMock();
        when(notifierMock.projectGroupDialogViewModel).thenReturn(null);
        when(notifierMock.hasConfiguredProjects).thenReturn(true);

        await mockNetworkImagesFor(
          () => tester.pumpWidget(_AddProjectGroupCardTestbed(
            projectGroupsNotifier: notifierMock,
          )),
        );

        await tester.tap(find.byType(AddProjectGroupCard));
        await tester.pump();

        expect(find.byType(AddProjectGroupDialog), findsNothing);
      },
    );

    testWidgets(
      "inits the project group dialog view model on tap on the card",
      (WidgetTester tester) async {
        final notifierMock = ProjectGroupsNotifierMock();
        when(notifierMock.hasConfiguredProjects).thenReturn(true);
        when(notifierMock.projectGroupDialogViewModel).thenReturn(
          ProjectGroupDialogViewModel(
            id: 'id',
            name: 'name',
            selectedProjectIds: UnmodifiableListView([]),
          ),
        );

        await mockNetworkImagesFor(
          () => tester.pumpWidget(_AddProjectGroupCardTestbed(
            projectGroupsNotifier: notifierMock,
          )),
        );

        await tester.tap(find.byType(AddProjectGroupCard));
        await tester.pump();

        verify(notifierMock.initProjectGroupDialogViewModel())
            .called(equals(1));
      },
    );

    testWidgets(
      "displays the network image with an add button svg",
      (WidgetTester tester) async {
        await mockNetworkImagesFor(
          () => tester.pumpWidget(const _AddProjectGroupCardTestbed()),
        );

        final networkImage = FinderUtil.findNetworkImageWidget(tester);

        expect(networkImage.url, equals('icons/add.svg'));
      },
    );

    testWidgets(
      "displays the disabled add icon svg when the card is disabled",
      (WidgetTester tester) async {
        final notifierMock = ProjectGroupsNotifierMock();
        when(notifierMock.hasConfiguredProjects).thenReturn(false);

        await mockNetworkImagesFor(
          () => tester.pumpWidget(_AddProjectGroupCardTestbed(
            projectGroupsNotifier: notifierMock,
          )),
        );

        final networkImage = FinderUtil.findNetworkImageWidget(tester);

        expect(networkImage.url, equals('icons/disabled-add.svg'));
      },
    );

    testWidgets(
      "displays the add project group text",
      (WidgetTester tester) async {
        await mockNetworkImagesFor(
          () => tester.pumpWidget(const _AddProjectGroupCardTestbed()),
        );

        expect(
          find.text(ProjectGroupsStrings.createGroup),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      "resets a project group dialog view model after closing the add project group dialog",
      (WidgetTester tester) async {
        final notifierMock = ProjectGroupsNotifierMock();
        when(notifierMock.hasConfiguredProjects).thenReturn(true);
        when(notifierMock.projectGroupDialogViewModel).thenReturn(
          ProjectGroupDialogViewModel(
            selectedProjectIds: UnmodifiableListView([]),
          ),
        );

        await mockNetworkImagesFor(
          () => tester.pumpWidget(_AddProjectGroupCardTestbed(
            projectGroupsNotifier: notifierMock,
          )),
        );

        await tester.tap(find.byType(AddProjectGroupCard));
        await tester.pump();

        expect(find.byType(AddProjectGroupDialog), findsOneWidget);

        final dialog = tester.widget<InfoDialog>(find.byType(InfoDialog));
        final closeIcon = dialog.closeIcon;

        await tester.tap(find.byWidget(closeIcon));
        await tester.pump();

        verify(notifierMock.resetProjectGroupDialogViewModel())
            .called(equals(1));
      },
    );
  });
}

/// A testbed widget, used to test the [AddProjectGroupCard] widget.
class _AddProjectGroupCardTestbed extends StatelessWidget {
  /// A [ProjectGroupsNotifier] used in tests.
  final ProjectGroupsNotifier projectGroupsNotifier;

  /// A [MetricsThemeData] used in tests.
  final MetricsThemeData theme;

  /// Creates the [_AddProjectGroupCardTestbed] with the given [theme]
  /// and the [projectGroupsNotifier].
  ///
  /// The [theme] defaults to [MetricsThemeData].
  const _AddProjectGroupCardTestbed({
    Key key,
    this.projectGroupsNotifier,
    this.theme = const MetricsThemeData(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TestInjectionContainer(
      projectGroupsNotifier: projectGroupsNotifier,
      child: MetricsThemedTestbed(
        metricsThemeData: theme,
        body: const AddProjectGroupCard(),
      ),
    );
  }
}
