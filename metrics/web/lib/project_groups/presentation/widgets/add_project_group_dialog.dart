import 'package:flutter/material.dart';
import 'package:metrics/project_groups/presentation/widgets/project_group_dialog.dart';
import 'package:metrics/project_groups/presentation/widgets/strategy/add_project_group_dialog_strategy.dart';

/// The widget that displays a dialog with the form for adding project group.
class AddProjectGroupDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strategy = AddProjectGroupDialogStrategy();

    return ProjectGroupDialog(
      strategy: strategy,
    );
  }
}
