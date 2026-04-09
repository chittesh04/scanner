import 'package:flutter/material.dart';

Future<String?> showTextValueDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? initialValue,
  String? hintText,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TextValueDialog(
      title: title,
      confirmLabel: confirmLabel,
      initialValue: initialValue,
      hintText: hintText,
    ),
  );
}

class _TextValueDialog extends StatefulWidget {
  const _TextValueDialog({
    required this.title,
    required this.confirmLabel,
    this.initialValue,
    this.hintText,
  });

  final String title;
  final String confirmLabel;
  final String? initialValue;
  final String? hintText;

  @override
  State<_TextValueDialog> createState() => _TextValueDialogState();
}

class _TextValueDialogState extends State<_TextValueDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(hintText: widget.hintText),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
