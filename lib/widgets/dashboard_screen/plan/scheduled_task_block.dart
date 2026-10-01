import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/scheduled_task.dart';
import 'package:cadence/data/sub_task.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/reusables/cadence_badge.dart';

class ScheduledTaskBlock extends StatelessWidget {
  const ScheduledTaskBlock({
    super.key,
    required this.scheduledTask,
    required this.onCheckTask,
    required this.onCheckSubTask,
  });

  final ScheduledTask scheduledTask;
  final void Function(bool) onCheckTask;
  final void Function(SubTask, bool) onCheckSubTask;

  Widget _buildSubTask(SubTask subTask) {
    final checked = subTask.completed;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: Checkbox(
            value: checked,
            onChanged: (newValue) => onCheckSubTask(subTask, newValue ?? false),
            activeColor: CadenceColors.otherAccent,
            side: BorderSide(color: CadenceColors.border, width: 1),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            subTask.name,
            softWrap: true,
            style: GoogleFonts.jetBrainsMono(
              color: checked
                  ? CadenceColors.textSecondary
                  : CadenceColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = scheduledTask.status;
    final statusColor = status.color;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: statusColor),
        color: CadenceColors.surface,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: scheduledTask.completed,
                        onChanged: (value) => onCheckTask(value ?? false),
                        side: BorderSide(color: statusColor),
                        activeColor: CadenceColors.accent,
                        checkColor: CadenceColors.black,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                scheduledTask.timeTextOneLine,
                                style: GoogleFonts.jetBrainsMono(
                                  color: CadenceColors.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(width: 10),

                              Flexible(
                                child: Text(
                                  scheduledTask.categoryName.toUpperCase(),
                                  overflow: .ellipsis,
                                  style: GoogleFonts.jetBrainsMono(
                                    color: CadenceColors.textSecondary,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Text(
                            scheduledTask.name,
                            style: GoogleFonts.jetBrainsMono(
                              color: CadenceColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight(1000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CadenceBadge(
                label: status.label.toUpperCase(),
                primaryColor: statusColor,
              ),
            ],
          ),

          if (scheduledTask.subTasks.isNotEmpty) ...[
            Divider(color: CadenceColors.border),

            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 25),
              child: Column(
                spacing: 10,
                children: [
                  for (final subTask in scheduledTask.subTasks)
                    _buildSubTask(subTask),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
