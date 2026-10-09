import 'package:cadence/utils/animations.dart';
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
    required this.onEdit,
  });

  final ScheduledTask scheduledTask;
  final void Function(bool) onCheckTask;
  final void Function(SubTask, bool) onCheckSubTask;
  final VoidCallback onEdit;

  Widget _buildSubTask(SubTask subTask) {
    final checked = subTask.completed;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: AnimatedCheckbox(
            value: checked,
            onChanged: (newValue) => onCheckSubTask(subTask, newValue),
            activeColor: CadenceColors.otherAccent,
            side: BorderSide(color: CadenceColors.border, width: 1),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: InkWell(
            onTap: () => onCheckSubTask(subTask, !checked),
            child: AnimatedDefaultTextStyle(
              duration: AnimationDurations.fast,
              style: GoogleFonts.jetBrainsMono(
                color: checked
                    ? CadenceColors.textSecondary
                    : CadenceColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                decoration: checked ? TextDecoration.lineThrough : null,
              ),
              child: Text(subTask.name, softWrap: true),
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
    final completed = scheduledTask.completed;

    return AnimatedContainer(
      duration: AnimationDurations.fast,
      curve: CadenceMotion.enter,
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
                      child: AnimatedCheckbox(
                        value: completed,
                        onChanged: onCheckTask,
                        side: BorderSide(color: statusColor),
                        activeColor: CadenceColors.accent,
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
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.jetBrainsMono(
                                    color: CadenceColors.textSecondary,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Flexible(
                                child: InkWell(
                                  onTap: () => onCheckTask(!completed),
                                  child: AnimatedDefaultTextStyle(
                                    duration: AnimationDurations.fast,
                                    curve: CadenceMotion.enter,
                                    style: GoogleFonts.jetBrainsMono(
                                      color: completed
                                          ? CadenceColors.textSecondary
                                          : CadenceColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      decoration: completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                    child: Text(scheduledTask.name),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: onEdit,
                                child: const Icon(
                                  Icons.edit_outlined,
                                  size: 12,
                                  color: CadenceColors.textSecondary,
                                ),
                              ),
                            ],
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
