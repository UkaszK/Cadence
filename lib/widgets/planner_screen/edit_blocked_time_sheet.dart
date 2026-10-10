import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/constants/app_constants.dart';
import 'package:cadence/theme/cadence_colors.dart';
import 'package:cadence/widgets/forms/fields/form_submit_button.dart';
import 'package:cadence/widgets/forms/fields/form_title_input_field.dart';

/// Opens a modal sheet to rename blocked time. Resolves with the new name, or
/// null if dismissed without saving.
Future<String?> showEditBlockedTimeSheet(BuildContext context, String name) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EditBlockedTimeSheet(name: name),
  );
}

class EditBlockedTimeSheet extends StatefulWidget {
  const EditBlockedTimeSheet({super.key, required this.name});

  final String name;

  @override
  State<EditBlockedTimeSheet> createState() => _EditBlockedTimeSheetState();
}

class _EditBlockedTimeSheetState extends State<EditBlockedTimeSheet> {
  late final _titleController = TextEditingController(text: widget.name);

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
  }

  void _onTitleChanged() => setState(() {});

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(_titleController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    const color = CadenceColors.blocked;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: CadenceColors.surface,
            border: const Border(top: BorderSide(width: 1, color: color)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.block, size: 16, color: color),
                          const SizedBox(width: 6),
                          Text(
                            'EDIT BLOCKED TIME',
                            style: GoogleFonts.jetBrainsMono(
                              color: color,
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
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  FormTitleInputField(
                    controller: _titleController,
                    maxLength: AppConstants.blockedTimeNameMaxLength,
                  ),
                  const SizedBox(height: 20),
                  FormSubmitButton(
                    onSubmit: _handleSubmit,
                    disabled: _titleController.text.trim().isEmpty,
                    primaryColor: color,
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
