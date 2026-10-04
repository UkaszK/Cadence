import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/data/task.dart';
import 'package:cadence/data/task_priority.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/get_duration_hours_and_minutes.dart';
import 'package:cadence/widgets/library_screen/item_container.dart';
import 'package:cadence/widgets/reusables/cadence_badge.dart';

String formatDurationLabel(int minutes) {
  final (h, m) = getDurationHoursAndMinutes(minutes);
  if (h == 0) return '${m}M';
  if (m == 0) return '${h}H';
  return '${h}H ${m}M';
}

class TaskBlock extends StatelessWidget {
  const TaskBlock({super.key, required this.task, this.footer});

  final Task task;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final color = task.archived
        ? CadenceColors.textSecondary
        : CadenceColors.accent;

    return ItemContainer(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 5,
                children: [
                  CadenceBadge(
                    label: task.archived ? 'ARCHIVED' : 'TASK',
                    primaryColor: color,
                  ),

                  CadenceBadge(
                    label: formatDurationLabel(task.durationMinutes),
                    primaryColor: CadenceColors.textSecondary,
                    backgroundColor: CadenceColors.surface,
                    borderColor: CadenceColors.border,
                    prefixIcon: Icons.timer_outlined,
                  ),

                  if (task.priority == TaskPriority.high)
                    CadenceBadge(
                      label: task.priority.label.toUpperCase(),
                      primaryColor: task.priority.color,
                      prefixIcon: task.priority.icon,
                    ),
                ],
              ),

              if (task.oneOff)
                Row(
                  spacing: 5,
                  children: [
                    Icon(Icons.calendar_today, color: color, size: 10),
                    Text(
                      'DUE: ${task.dueText}',
                      style: GoogleFonts.jetBrainsMono(
                        color: CadenceColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            task.name,
            style: GoogleFonts.jetBrainsMono(
              color: CadenceColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight(1000),
            ),
          ),

          if (task.subTasks.isNotEmpty) ...[
            const SizedBox(height: 10),

            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CadenceColors.black,
                border: Border.all(color: CadenceColors.border, width: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Icon(Icons.checklist, size: 14, color: color),
                      ),
                      Text(
                        'SUB-TASKS',
                        style: GoogleFonts.jetBrainsMono(
                          color: CadenceColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  for (final subTask in task.subTasks)
                    Row(
                      spacing: 5,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Icon(
                            Icons.chevron_right,
                            color: color,
                            size: 14,
                          ),
                        ),
                        Text(
                          subTask,
                          style: GoogleFonts.jetBrainsMono(
                            color: CadenceColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],

          if (footer != null) ...[
            const SizedBox(height: 10),
            Divider(height: 1),
            const SizedBox(height: 5),
            footer!,
          ],
        ],
      ),
    );
  }
}
