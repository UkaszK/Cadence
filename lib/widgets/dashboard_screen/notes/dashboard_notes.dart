import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/constants/app_constants.dart';
import 'package:cadence/data/quick_note.dart';
import 'package:cadence/providers/quick_note_providers.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/utils/animations.dart';
import 'package:cadence/widgets/reusables/cadence_section_header.dart';

/// Small per-day scratchpad on the dashboard: a checklist of quick notes
/// belonging to [date].
class DashboardNotes extends ConsumerStatefulWidget {
  const DashboardNotes({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<DashboardNotes> createState() => _DashboardNotesState();
}

class _DashboardNotesState extends ConsumerState<DashboardNotes> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    QuickNoteService.add(_controller.text, widget.date);
    _controller.clear();
    _focusNode.requestFocus();
  }

  Widget _buildHeader(List<QuickNote> notes) {
    final done = notes.where((n) => n.completed).length;

    return CadenceSectionHeader(
      title: 'NOTES',
      icon: Icons.sticky_note_2_outlined,
      iconColor: CadenceColors.gold,
      dividerStyle: (dividerDistance: 8),
      rightSide: Row(
        children: [
          if (done > 0) ...[
            InkWell(
              onTap: () => QuickNoteService.clearCompleted(widget.date),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'CLEAR DONE',
                  style: GoogleFonts.jetBrainsMono(
                    color: CadenceColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            notes.isEmpty ? 'SCRATCHPAD' : '$done / ${notes.length} DONE',
            style: GoogleFonts.jetBrainsMono(
              color: CadenceColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHint() {
    return DottedBorder(
      options: RectDottedBorderOptions(
        strokeWidth: 1,
        color: CadenceColors.border,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Icon(
              Icons.edit_note,
              size: 18,
              color: CadenceColors.gold.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Jot down reminders, ideas or small to-dos that don\'t need a full task.',
                style: GoogleFonts.jetBrainsMono(
                  color: CadenceColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    final canSubmit = _controller.text.trim().isNotEmpty;

    return GestureDetector(
      onTap: _focusNode.requestFocus,
      child: AnimatedContainer(
        duration: AnimationDurations.fast,
        curve: CadenceMotion.enter,
        height: 44,
        padding: const EdgeInsets.only(left: 12, right: 4),
        decoration: BoxDecoration(
          color: CadenceColors.surface,
          border: Border.all(
            width: 1,
            color: _focusNode.hasFocus
                ? CadenceColors.gold
                : CadenceColors.border,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, size: 16, color: CadenceColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autocorrect: false,
                maxLength: AppConstants.quickNoteMaxLength,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                cursorColor: CadenceColors.textSecondary,
                style: GoogleFonts.jetBrainsMono(fontSize: 12),
                decoration: InputDecoration(
                  counterText: '',
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: 'Add a quick note...',
                  hintStyle: GoogleFonts.jetBrainsMono(
                    color: CadenceColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              duration: AnimationDurations.fast,
              opacity: canSubmit ? 1 : 0.35,
              child: IconButton(
                onPressed: canSubmit ? _submit : null,
                tooltip: 'Add note',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.keyboard_return,
                  size: 18,
                  color: CadenceColors.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(quickNotesForDayProvider(widget.date));
    final notes = notesAsync.value ?? const <QuickNote>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(notes),

        const SizedBox(height: 10),

        if (notes.isEmpty)
          _buildEmptyHint()
        else
          Container(
            decoration: BoxDecoration(
              color: CadenceColors.surface,
              border: Border.all(width: 1, color: CadenceColors.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < notes.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: CadenceColors.border),
                  _QuickNoteRow(
                    key: ValueKey(notes[i].id),
                    note: notes[i],
                    onCheck: (value) =>
                        QuickNoteService.setCompleted(notes[i], value),
                    onDelete: () => QuickNoteService.delete(notes[i]),
                  ),
                ],
              ],
            ),
          ),

        const SizedBox(height: 10),

        _buildInput(),
      ],
    );
  }
}

class _QuickNoteRow extends StatelessWidget {
  const _QuickNoteRow({
    super.key,
    required this.note,
    required this.onCheck,
    required this.onDelete,
  });

  final QuickNote note;
  final void Function(bool) onCheck;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss-${note.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: CadenceColors.danger.withValues(alpha: 0.25),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete_outline,
          size: 18,
          color: CadenceColors.textPrimary,
        ),
      ),
      child: InkWell(
        onTap: () => onCheck(!note.completed),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: AnimatedCheckbox(
                  value: note.completed,
                  onChanged: onCheck,
                  activeColor: CadenceColors.gold,
                  side: const BorderSide(color: CadenceColors.gold, width: 1),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: AnimationDurations.fast,
                  curve: CadenceMotion.enter,
                  style: GoogleFonts.jetBrainsMono(
                    color: note.completed
                        ? CadenceColors.textSecondary
                        : CadenceColors.textPrimary,
                    fontSize: 12,
                    decoration: note.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  child: Text(note.text),
                ),
              ),

              const SizedBox(width: 8),

              SizedBox(
                width: 24,
                height: 24,
                child: InkWell(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: CadenceColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
