import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyButton extends StatelessWidget {
  const CopyButton({
    super.key,
    required this.textToCopy,
  });

  final String textToCopy;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Copy text',
      onPressed: () {
        Clipboard.setData(
          ClipboardData(text: textToCopy),
        );
      },
      icon: const Icon(Icons.copy_rounded),
    );
  }
}
