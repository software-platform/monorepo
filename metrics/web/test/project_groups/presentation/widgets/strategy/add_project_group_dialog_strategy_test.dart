import 'package:metrics/project_groups/presentation/state/project_groups_notifier.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:metrics/project_groups/presentation/widgets/strategy/add_project_group_dialog_strategy.dart';
import 'package:metrics/project_groups/presentation/strings/project_groups_strings.dart';

void main() {
  group("AddProjectGroupDialogStrategy", () {
    final strategy = AddProjectGroupDialogStrategy();

    test(
      ".loadingText equals to the ProjectGroupsStrings.creatingGroup",
      () {
        expect(
          strategy.loadingText,
          equals(ProjectGroupsStrings.creatingProjectGroup),
        );
      },
    );

    test(".text equals to the ProjectGroupString.createGroup", () {
      expect(
        strategy.text,
        equals(ProjectGroupsStrings.createGroup),
      );
    });

    test(".title equals to the ProjectGroupString.addProjectGroup", () {
      expect(
        strategy.title,
        equals(ProjectGroupsStrings.addProjectGroup),
      );
    });

    test(
      ".action() delegates adding a new project group to the given notifier",
      () {
        const id = 'groupId';
        const name = 'groupName';
        const projectIds = <String>[];
        final notifier = ProjectGroupNotifierMock();

        strategy.action(notifier, id, name, projectIds);

        verify(notifier.addProjectGroup(id, name, projectIds))
            .called(equals(1));
      },
    );
  });
}

class ProjectGroupNotifierMock extends Mock implements ProjectGroupsNotifier {}
