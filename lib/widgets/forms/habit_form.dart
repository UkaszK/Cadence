import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/day.dart';
import 'package:cadence/data/habit.dart';
import 'package:cadence/data/task_categories.dart';
import 'package:cadence/data/task_category.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/DateTime/date_time_extension.dart';
import 'package:cadence/widgets/forms/fields/cadence_switch.dart';
import 'package:cadence/widgets/forms/fields/form_category_selector.dart';
import 'package:cadence/widgets/forms/fields/form_day_selector.dart';
import 'package:cadence/widgets/forms/fields/form_duration_field.dart';
import 'package:cadence/widgets/forms/fields/form_interval_field.dart';
import 'package:cadence/widgets/forms/fields/form_submit_button.dart';
import 'package:cadence/widgets/forms/fields/form_title_input_field.dart';

const int _defaultHabitDurationMinutes = 15;
const int _minIntervalDays = 2;

class HabitForm extends StatefulWidget {
  const HabitForm({super.key, required this.onSubmit, this.editingHabit});

  final void Function(Habit) onSubmit;
  final Habit? editingHabit;

  @override
  State<StatefulWidget> createState() => _HabitFormState();
}

class _HabitFormState extends State<HabitForm> {
  TaskCategory _category = taskCategories.first;
  final _titleController = TextEditingController();
  int? _durationMinutes = _defaultHabitDurationMinutes;
  HabitScheduleType _scheduleType = HabitScheduleType.weekdays;
  Set<Day> _repeatDays = {};
  int _intervalDays = _minIntervalDays;
  DateTime _anchorDate = DateTime.now().dateOnly;
  bool _startDateChosen = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);

    final editing = widget.editingHabit;
    if (editing != null) {
      _category = editing.category;
      _titleController.text = editing.name;
      _durationMinutes = editing.durationMinutes;
      _scheduleType = editing.scheduleType;
      _repeatDays = editing.repeatDaySet;
      _intervalDays = editing.intervalDays ?? _minIntervalDays;
      _anchorDate = editing.anchorDate?.dateOnly ?? DateTime.now().dateOnly;
    }
  }

  void _onTitleChanged() => setState(() {});

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    super.dispose();
  }

  bool get _scheduleValid => switch (_scheduleType) {
    HabitScheduleType.weekdays => _repeatDays.isNotEmpty,
    HabitScheduleType.interval => _intervalDays >= _minIntervalDays,
  };

  void _submitForm() {
    final isInterval = _scheduleType == HabitScheduleType.interval;

    final habit = Habit(
      categoryName: _category.name,
      name: _titleController.text.trim(),
      durationMinutes: _durationMinutes!,
      scheduleType: _scheduleType,
      repeatDays: isInterval ? const [] : _repeatDays.toList(),
      intervalDays: isInterval ? _intervalDays : null,
      anchorDate: isInterval ? _anchorDate : null,
      archived: widget.editingHabit?.archived ?? false,
    );

    widget.onSubmit(habit);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitDisabled =
        _titleController.text.trim().isEmpty ||
        _durationMinutes == null ||
        !_scheduleValid;

    return Form(
      child: Column(
        spacing: 15,
        crossAxisAlignment: .start,
        children: [
          FormCategorySelector(
            taskCategories: taskCategories,
            selection: _category,
            onChange: (category) => setState(() => _category = category),
            primaryColor: CadenceColors.otherAccent,
          ),

          FormTitleInputField(controller: _titleController),

          FormDurationField(
            minutes: _durationMinutes,
            onChange: (minutes) => setState(() => _durationMinutes = minutes),
          ),

          Column(
            crossAxisAlignment: .start,
            spacing: 8,
            children: [
              Text(
                'SCHEDULE',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              CadenceSwitch<HabitScheduleType>(
                options: HabitScheduleType.values,
                selection: _scheduleType,
                labelOf: (type) => switch (type) {
                  HabitScheduleType.weekdays => 'ON WEEKDAYS',
                  HabitScheduleType.interval => 'EVERY N DAYS',
                },
                primaryColorOf: (_) => CadenceColors.otherAccent,
                onChange: (type) => setState(() => _scheduleType = type),
              ),
            ],
          ),

          switch (_scheduleType) {
            HabitScheduleType.weekdays => FormDaySelector(
              weekdays: Day.values.toSet(),
              selection: _repeatDays,
              onChange: (repeatDays) =>
                  setState(() => _repeatDays = repeatDays),
            ),
            HabitScheduleType.interval => FormIntervalField(
              intervalDays: _intervalDays,
              startDate: _anchorDate,
              minIntervalDays: _minIntervalDays,
              onIntervalChange: (days) => setState(() {
                _intervalDays = days;
                // Changing the rhythm restarts the cycle from the chosen
                // start date (today unless picked explicitly).
                if (!_startDateChosen) _anchorDate = DateTime.now().dateOnly;
              }),
              onStartDateChange: (date) => setState(() {
                _anchorDate = date.dateOnly;
                _startDateChosen = true;
              }),
            ),
          },

          FormSubmitButton(
            onSubmit: _submitForm,
            disabled: isSubmitDisabled,
            primaryColor: CadenceColors.otherAccent,
          ),
        ],
      ),
    );
  }
}
