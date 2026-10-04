import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cadence/theme/cadence_colors.dart';

class FormSubTasksField<T> extends StatefulWidget {
  const FormSubTasksField({
    super.key,
    required this.items,
    required this.onChange,
    required this.labelOf,
    required this.create,
    required this.rename,
    this.leadingBuilder,
  });

  /// Convenience constructor for plain string sub tasks.
  static FormSubTasksField<String> strings({
    Key? key,
    required List<String> items,
    required void Function(List<String>) onChange,
  }) {
    return FormSubTasksField<String>(
      key: key,
      items: items,
      onChange: onChange,
      labelOf: (item) => item,
      create: (text) => text,
      rename: (_, text) => text,
    );
  }

  final List<T> items;
  final void Function(List<T>) onChange;
  final String Function(T item) labelOf;
  final T Function(String text) create;
  final T Function(T item, String text) rename;
  final Widget Function(T item)? leadingBuilder;

  @override
  State<StatefulWidget> createState() => _FormSubTasksFieldState<T>();
}

class _FormSubTasksFieldState<T> extends State<FormSubTasksField<T>> {
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _editController = TextEditingController();

  final FocusNode _newFocusNode = FocusNode();
  final FocusNode _editFocusNode = FocusNode();

  int? _editingIndex;
  bool _newFocused = false;
  late List<UniqueKey> _itemKeys;

  final double subTaskFieldHeight = 40;

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(widget.items.length, (_) => UniqueKey());

    _newFocusNode.addListener(() {
      setState(() {
        _newFocused = _newFocusNode.hasFocus;
      });
      if (!_newFocusNode.hasFocus) {
        _trySaveNew();
      }
    });

    _editFocusNode.addListener(() {
      setState(() {});
      if (!_editFocusNode.hasFocus && _editingIndex != null) {
        _saveEdit(_editingIndex!);
      }
    });
  }

  @override
  void didUpdateWidget(FormSubTasksField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_itemKeys.length < widget.items.length) {
      _itemKeys.addAll(
        List.generate(
          widget.items.length - _itemKeys.length,
          (_) => UniqueKey(),
        ),
      );
    } else if (_itemKeys.length > widget.items.length) {
      _itemKeys.removeRange(widget.items.length, _itemKeys.length);
    }
  }

  @override
  void dispose() {
    _newController.dispose();
    _editController.dispose();
    _newFocusNode.dispose();
    _editFocusNode.dispose();
    super.dispose();
  }

  void _trySaveNew() {
    final text = _newController.text.trim();
    if (text.isNotEmpty) {
      List<T> updated = [...widget.items, widget.create(text)];
      _itemKeys.add(UniqueKey());
      widget.onChange(updated);
      _newController.clear();
    }
  }

  void _saveEdit(int index) {
    if (_editingIndex != index) return;

    final text = _editController.text.trim();
    List<T> updated = List.from(widget.items);

    if (text.isNotEmpty) {
      updated[index] = widget.rename(updated[index], text);
    } else {
      updated.removeAt(index);
      _itemKeys.removeAt(index);
    }

    widget.onChange(updated);

    setState(() {
      _editingIndex = null;
    });
  }

  void _deleteItem(int index) {
    List<T> updated = List.from(widget.items);
    updated.removeAt(index);
    _itemKeys.removeAt(index);
    widget.onChange(updated);

    if (_editingIndex == index) {
      setState(() {
        _editingIndex = null;
      });
    }
  }

  void _reorderItems(int oldIndex, int newIndex) {
    if (_editingIndex != null) return;

    final updated = List<T>.from(widget.items);
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);

    final key = _itemKeys.removeAt(oldIndex);
    _itemKeys.insert(newIndex, key);
    widget.onChange(updated);
  }

  Widget _buildSavedItem(int index, T item) {
    final isEditing = _editingIndex == index;
    final label = widget.labelOf(item);

    return Row(
      children: [
        if (widget.items.length > 1) ...[
          SizedBox(
            width: 32,
            height: subTaskFieldHeight,
            child: _editingIndex == null
                ? ReorderableDragStartListener(
                    index: index,
                    child: const Tooltip(
                      message: 'Drag to reorder',
                      child: Icon(
                        Icons.drag_indicator,
                        size: 20,
                        color: CadenceColors.textSecondary,
                      ),
                    ),
                  )
                : const Tooltip(
                    message: 'Finish editing to reorder',
                    child: Icon(
                      Icons.drag_indicator,
                      size: 20,
                      color: CadenceColors.border,
                    ),
                  ),
          ),
        ],

        SizedBox(
          width: 20,
          height: 20,
          child:
              widget.leadingBuilder?.call(item) ??
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: CadenceColors.accent,
              ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: isEditing
              ? GestureDetector(
                  onTap: () => _editFocusNode.requestFocus(),
                  child: Container(
                    height: subTaskFieldHeight,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: _editFocusNode.hasFocus
                            ? CadenceColors.accent
                            : CadenceColors.border,
                      ),
                    ),
                    child: TextFormField(
                      controller: _editController,
                      focusNode: _editFocusNode,
                      autocorrect: false,
                      maxLength: 25,
                      onFieldSubmitted: (_) => _saveEdit(index),
                      cursorColor: CadenceColors.textSecondary,
                      style: GoogleFonts.jetBrainsMono(fontSize: 12),
                      decoration: const InputDecoration(
                        counterText: '',
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                )
              : InkWell(
                  onTap: () {
                    setState(() {
                      _editingIndex = index;
                      _editController.text = label;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _editFocusNode.requestFocus();
                    });
                  },
                  child: Container(
                    height: subTaskFieldHeight,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: CadenceColors.border),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.jetBrainsMono(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
        ),

        const SizedBox(width: 8),

        SizedBox(
          width: 24,
          height: 24,
          child: InkWell(
            onTap: () => _deleteItem(index),
            child: const Icon(
              Icons.delete_outline,
              size: 20,
              color: CadenceColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewSubTaskInputField() {
    return GestureDetector(
      onTap: () {
        _newFocusNode.requestFocus();
      },
      child: Container(
        height: subTaskFieldHeight,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: _newFocused ? CadenceColors.accent : CadenceColors.border,
          ),
        ),
        child: TextFormField(
          controller: _newController,
          focusNode: _newFocusNode,
          autocorrect: false,
          onFieldSubmitted: (_) => _trySaveNew(),
          maxLength: 25,
          cursorColor: CadenceColors.textSecondary,
          style: GoogleFonts.jetBrainsMono(fontSize: 12),
          decoration: InputDecoration(
            counterText: '',
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            hintText: 'Sub-task description...',
            hintStyle: GoogleFonts.jetBrainsMono(
              color: CadenceColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SUB-TASKS (Optional)',
              style: GoogleFonts.jetBrainsMono(
                color: CadenceColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () => _trySaveNew(),
              child: Row(
                spacing: 5,
                children: [
                  const Icon(Icons.add, color: CadenceColors.accent, size: 14),
                  Text(
                    'ADD TASK',
                    style: GoogleFonts.jetBrainsMono(
                      color: CadenceColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (widget.items.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: widget.items.length,
            onReorderItem: _reorderItems,
            itemBuilder: (context, index) => Padding(
              key: _itemKeys[index],
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSavedItem(index, widget.items[index]),
            ),
          ),

        _buildNewSubTaskInputField(),
      ],
    );
  }
}
