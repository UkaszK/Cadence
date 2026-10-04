import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/task.dart';
import 'package:cadence/data/task_categories.dart';
import 'package:cadence/data/task_category.dart';
import 'package:cadence/data/task_priority.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/forms/fields/form_category_selector.dart';
import 'package:cadence/widgets/forms/fields/form_due_date_field.dart';
import 'package:cadence/widgets/forms/fields/form_duration_field.dart';
import 'package:cadence/widgets/forms/fields/form_priority_selector.dart';
import 'package:cadence/widgets/forms/fields/form_sub_tasks_field.dart';
import 'package:cadence/widgets/forms/fields/form_submit_button.dart';
import 'package:cadence/widgets/forms/fields/form_title_input_field.dart';

const int _defaultTaskDurationMinutes = 60;

class TaskForm extends StatefulWidget {
  const TaskForm({super.key, required this.onSubmit, this.editingTask});

  final void Function(Task) onSubmit;
  final Task? editingTask;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  TaskCategory _category = taskCategories.first;
  final _titleController = TextEditingController();
  int? _durationMinutes = _defaultTaskDurationMinutes;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.normal;
  List<String> _subTasks = [];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);

    final editing = widget.editingTask;
    if (editing != null) {
      _category = editing.category;
      _titleController.text = editing.name;
      _durationMinutes = editing.durationMinutes;
      _dueDate = editing.dueDate;
      _priority = editing.priority;
      _subTasks = editing.subTasks;
    }
  }

  void _onTitleChanged() => setState(() {});

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final task = Task(
      name: _titleController.text.trim(),
      categoryName: _category.name,
      priority: _priority,
      durationMinutes: _durationMinutes!,
      dueDate: _dueDate,
      subTasks: _subTasks,
      archived: widget.editingTask?.archived ?? false,
    );

    widget.onSubmit(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitDisabled =
        _titleController.text.trim().isEmpty || _durationMinutes == null;

    return Form(
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormCategorySelector(
            taskCategories: taskCategories,
            selection: _category,
            onChange: (category) => setState(() => _category = category),
          ),

          FormTitleInputField(controller: _titleController),

          FormDurationField(
            minutes: _durationMinutes,
            onChange: (minutes) => setState(() => _durationMinutes = minutes),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              FormDueDateField(
                selectedDate: _dueDate,
                onChange: (date) => setState(() => _dueDate = date),
              ),
              Text(
                'Tasks with a due date are archived automatically once completed.',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),

          FormPrioritySelector(
            priorities: TaskPriority.values,
            selection: _priority,
            onChange: (priority) => setState(() => _priority = priority),
          ),

          Divider(height: 20),

          FormSubTasksField.strings(
            items: _subTasks,
            onChange: (subTasks) => setState(() => _subTasks = subTasks),
          ),

          FormSubmitButton(onSubmit: _handleSubmit, disabled: isSubmitDisabled),
        ],
      ),
    );
  }
}
