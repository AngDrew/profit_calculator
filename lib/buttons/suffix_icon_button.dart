import 'package:flutter/material.dart';

class SuffixIconButton extends StatelessWidget {
  const SuffixIconButton({
    Key? key,
    required TextEditingController controller,
  })  : _controller = controller,
        super(key: key);

  final TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _controller.clear,
      icon: const Icon(Icons.clear_rounded),
    );
  }
}
