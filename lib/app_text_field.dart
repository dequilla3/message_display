import 'package:flutter/material.dart';
import 'package:wsmessage/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChange;
  final bool isObscureText;
  final FocusNode? focusNode;
  final int? maxLines;
  const AppTextField(
      {super.key,
      this.hint,
      this.controller,
      this.onChange,
      this.isObscureText = false,
      this.focusNode,
      this.maxLines});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(fontSize: 14),
      obscureText: isObscureText,
      onChanged: onChange,
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
          isDense: true,
          labelText: hint,
          labelStyle: const TextStyle(color: AppColors.font2, fontSize: 14),
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
          ),
          filled: true,
          fillColor: AppColors.secondary),
    );
  }
}
