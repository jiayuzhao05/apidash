import 'dart:math' as math;
import 'package:apidash/consts.dart';
import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _TextFieldEditorState extends State<TextFieldEditor> {
  late TextEditingController controller;
  late final FocusNode editorFocusNode;

  void insertTab() {
    const sp = "  ";
    final offset = math.min(
      controller.selection.baseOffset,
      controller.selection.extentOffset,
    );

    final text = controller.text.substring(0, offset) +
        sp +
        controller.text.substring(offset);

    controller.value = TextEditingValue(
      text: text,
      selection: controller.selection.copyWith(
        baseOffset: controller.selection.baseOffset + sp.length,
        extentOffset: controller.selection.extentOffset + sp.length,
      ),
    );
    widget.onChanged?.call(text);
  }

  @override
  void initState() {
    super.initState();
    editorFocusNode = FocusNode(debugLabel: "Editor Focus Node");

    final initialText = widget.initialValue ?? '';
    controller = TextEditingController.fromValue(
      TextEditingValue(
        text: initialText,
        selection: TextSelection.collapsed(offset: initialText.length),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant TextFieldEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 1) fieldKey changed => treat as a different field/request.
    // Reset controller with new text and put cursor at end.
    if (oldWidget.fieldKey != widget.fieldKey) {
      final newText = widget.initialValue ?? '';
      controller.dispose();
      controller = TextEditingController.fromValue(
        TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        ),
      );
      return;
    }

    // 2) Same fieldKey, but initialValue updated externally:
    // Update text only if needed, preserve selection (range) with clamping.
    final newValue = widget.initialValue;
    if (newValue != null &&
        oldWidget.initialValue != newValue &&
        controller.text != newValue) {
      final oldSel = controller.selection;

      controller.value = controller.value.copyWith(
        text: newValue,
        composing: TextRange.empty,
      );

      // Clamp both base & extent to the new text length.
      final len = controller.text.length;
      int clamp(int v) => v.clamp(0, len);

      final base = clamp(oldSel.baseOffset);
      final extent = clamp(oldSel.extentOffset);

      controller.selection = TextSelection(
        baseOffset: base,
        extentOffset: extent,
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANT: do NOT set controller.text here.
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.tab): insertTab,
      },
      child: TextFormField(
        key: Key(widget.fieldKey),
        controller: controller,
        focusNode: editorFocusNode,
        keyboardType: TextInputType.multiline,
        expands: true,
        maxLines: null,
        readOnly: widget.readOnly,
        style: kCodeStyle.copyWith(
          fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
        ),
        textAlignVertical: TextAlignVertical.top,
        onChanged: widget.onChanged,
        onTapOutside: (PointerDownEvent event) {
          editorFocusNode.unfocus();
        },
        decoration: InputDecoration(
          hintText: widget.hintText ?? kHintContent,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: kBorderRadius8,
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: kBorderRadius8,
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          filled: true,
          hoverColor: kColorTransparent,
          fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
      ),
    );
  }
}