import 'package:cadence/utils/animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/data/sub_task.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/forms/fields/form_submit_button.dart';
import 'package:cadence/widgets/forms/fields/form_sub_tasks_field.dart';
import 'package:cadence/widgets/forms/fields/form_title_input_field.dart';

typedef ScheduledTaskDetails = ({String name, List<SubTask> subTasks});

/// Opens a modal sheet to edit name and sub tasks of a scheduled task.
/// Resolves with the edited details, or null if dismissed without saving.
Future<ScheduledTaskDetails?> showEditScheduledTaskSheet(
  BuildContext context,
  ScheduledTask scheduledTask,
) {
  return showModalBottomSheet<ScheduledTaskDetails>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EditScheduledTaskSheet(scheduledTask: scheduledTask),
  );
}

class EditScheduledTaskSheet extends StatefulWidget {
  const EditScheduledTaskSheet({super.key, required this.scheduledTask});

  final ScheduledTask scheduledTask;

  @override
  State<EditScheduledTaskSheet> createState() => _EditScheduledTaskSheetState();
}

class _EditScheduledTaskSheetState extends State<EditScheduledTaskSheet> {
  final _titleController = TextEditingController();
  late List<SubTask> _subTasks;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.scheduledTask.name;
    _titleController.addListener(_onTitleChanged);
    _subTasks = List.of(widget.scheduledTask.subTasks);
  }

  void _onTitleChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(
      context,
    ).pop((name: _titleController.text.trim(), subTasks: _subTasks));
  }

  Widget _buildSubTaskLeading(SubTask subTask) {
    return Icon(
      subTask.completed ? Icons.check_circle : Icons.chevron_right,
      size: 20,
      color: subTask.completed ? CadenceColors.success : CadenceColors.accent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitDisabled = _titleController.text.trim().isEmpty;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: CadenceColors.surface,
            border: const Border(
              top: BorderSide(width: 1, color: CadenceColors.accent),
            ),
            boxShadow: [
              BoxShadow(
                color: CadenceColors.accent.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeInTransition(
                    delay: Duration.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: CadenceColors.accent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'EDIT TASK',
                              style: GoogleFonts.jetBrainsMono(
                                color: CadenceColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: CadenceColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  FadeInTransition(
                    delay: const Duration(milliseconds: 100),
                    child: FormTitleInputField(controller: _titleController),
                  ),
                  const SizedBox(height: 20),
                  FadeInTransition(
                    delay: const Duration(milliseconds: 150),
                    child: FormSubTasksField<SubTask>(
                      items: _subTasks,
                      onChange: (subTasks) =>
                          setState(() => _subTasks = subTasks),
                      labelOf: (subTask) => subTask.name,
                      create: (text) => SubTask(name: text),
                      rename: (subTask, text) =>
                          SubTask(name: text, completed: subTask.completed),
                      leadingBuilder: _buildSubTaskLeading,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInTransition(
                    delay: const Duration(milliseconds: 200),
                    child: FormSubmitButton(
                      onSubmit: _handleSubmit,
                      disabled: isSubmitDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
