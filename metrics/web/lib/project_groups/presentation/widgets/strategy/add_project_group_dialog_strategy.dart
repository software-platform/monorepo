import 'package:metrics/project_groups/presentation/state/project_groups_notifier.dart';
import 'package:metrics/project_groups/presentation/strings/project_groups_strings.dart';
import 'package:metrics/project_groups/presentation/widgets/add_project_group_dialog.dart';
import 'package:metrics/project_groups/presentation/widgets/strategy/project_group_dialog_strategy.dart';

/// The [ProjectGroupDialogStrategy] implementation for the [AddProjectGroupDialog] 
/// and adding a new project group.
class AddProjectGroupDialogStrategy implements ProjectGroupDialogStrategy {
  @override
  final String loadingText = ProjectGroupsStrings.creatingProjectGroup;

  @override
  final String text = ProjectGroupsStrings.createGroup;

  @override
  final String title = ProjectGroupsStrings.addProjectGroup;

  @override
  Future<void> action(
    ProjectGroupsNotifier notifier,
    String groupId,
    String groupName,
    List<String> projectIds,
  ) {
    return notifier.addProjectGroup(groupId, groupName, projectIds);
  }
}
