import 'package:flutter/material.dart';

class ClickableTextField extends StatelessWidget {
  final VoidCallback onTap;
  final TextEditingController controller;

  const ClickableTextField({
    Key? key,
    required this.onTap,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: TextField(
          decoration: InputDecoration(enabled: false),
          controller: controller,
        ),
      ),
    );
  }
}
