import 'dart:async';

import 'package:flutter/material.dart';
import 'package:metrics/base/presentation/widgets/clearable_text_form_field.dart';
import 'package:metrics/base/presentation/widgets/info_dialog.dart';
import 'package:metrics/common/presentation/metrics_theme/widgets/metrics_theme.dart';
import 'package:metrics/common/presentation/strings/common_strings.dart';
import 'package:metrics/project_groups/presentation/state/project_groups_notifier.dart';
import 'package:metrics/project_groups/presentation/strings/project_groups_strings.dart';
import 'package:metrics/project_groups/presentation/validators/project_group_name_validator.dart';
import 'package:metrics/project_groups/presentation/view_models/project_group_dialog_view_model.dart';
import 'package:metrics/project_groups/presentation/widgets/project_checkbox_list.dart';
import 'package:metrics/project_groups/presentation/widgets/strategy/project_group_dialog_strategy.dart';
import 'package:provider/provider.dart';

/// The widget that displays a dialog with the form for adding project group.
class ProjectGroupDialog extends StatefulWidget {
  /// A [ProjectGroupDialogStrategy] strategy applied to this dialog.
  final ProjectGroupDialogStrategy strategy;

  /// Creates a new instance of the [ProjectGroupDialog]
  /// with the given [strategy].
  ///
  /// The [strategy] must not be null.
  const ProjectGroupDialog({
    Key key,
    @required this.strategy,
  })  : assert(strategy != null),
        super(key: key);

  @override
  _ProjectGroupDialogState createState() => _ProjectGroupDialogState();
}

class _ProjectGroupDialogState extends State<ProjectGroupDialog> {
  /// A group name text editing controller.
  final TextEditingController _groupNameController = TextEditingController();

  /// A global key that uniquely identifies the [Form] widget
  /// and allows validation of the form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// The [ChangeNotifier] that holds the project groups state.
  ProjectGroupsNotifier _projectGroupsNotifier;

  /// Indicates whether this widget is in the loading state or not.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _projectGroupsNotifier = Provider.of<ProjectGroupsNotifier>(
      context,
      listen: false,
    );

    _groupNameController.text =
        _projectGroupsNotifier?.projectGroupDialogViewModel?.name;
  }

  @override
  Widget build(BuildContext context) {
    final dialogTheme = MetricsTheme.of(context).dialogThemeData;
    final strategy = widget.strategy;

    return Selector<ProjectGroupsNotifier, ProjectGroupDialogEditViewModel>(
      selector: (_, state) => state.projectGroupDialogViewModel,
      builder: (_, projectGroup, __) {
        final buttonText = _isLoading ? strategy.loadingText : strategy.text;

        return InfoDialog(
          padding: dialogTheme.padding,
          title: Text(
            strategy.title,
            style: dialogTheme.titleTextStyle,
          ),
          titlePadding: dialogTheme.titlePadding,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _formKey,
                child: ClearableTextFormField(
                  validator: ProjectGroupNameValidator.validate,
                  label: ProjectGroupsStrings.nameYourGroup,
                  controller: _groupNameController,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(ProjectGroupsStrings.chooseProjectToAdd),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        onChanged: _projectGroupsNotifier.filterByProjectName,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: CommonStrings.searchForProject,
                        ),
                      ),
                      Flexible(
                        child: ProjectCheckboxList(),
                      ),
                    ],
                  ),
                ),
              ),
              Text(_getCounterText(projectGroup)),
            ],
          ),
          contentPadding: dialogTheme.contentPadding,
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  onPressed:
                      _isLoading ? null : () => _actionCallback(projectGroup),
                  child: Text(buttonText),
                ),
              ],
            ),
          ],
          actionsPadding: dialogTheme.actionsPadding,
        );
      },
    );
  }

  /// Returns a text to display as a counter for the selected projects.
  String _getCounterText(ProjectGroupDialogEditViewModel projectGroup) {
    final selectedProjectIds = projectGroup.selectedProjectIds;

    if (selectedProjectIds.isEmpty) return '';

    return ProjectGroupsStrings.getSelectedCount(selectedProjectIds.length);
  }

  /// A callback for this dialog action button.
  Future<void> _actionCallback(
      ProjectGroupDialogEditViewModel projectGroup) async {
    if (!_formKey.currentState.validate()) return;

    _changeLoading(true);

    await widget.strategy.action(
      _projectGroupsNotifier,
      projectGroup.id,
      _groupNameController.text,
      projectGroup.selectedProjectIds,
    );

    _changeLoading(false);

    final projectGroupSavingError =
        _projectGroupsNotifier.projectGroupSavingError;

    if (projectGroupSavingError == null) {
      Navigator.pop(context);
    }
  }

  /// Changes the [_isLoading] state to the given [value].
  void _changeLoading(bool value) {
    setState(() => _isLoading = value);
  }

  @override
  void dispose() {
    _projectGroupsNotifier.resetFilterName();
    _groupNameController.dispose();
    super.dispose();
  }
}
