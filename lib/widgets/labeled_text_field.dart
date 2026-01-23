import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/theme.dart';

class LabeledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? hint;
  final Widget? prefix;
  final Widget? suffix;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const LabeledTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.hint,
    this.prefix,
    this.suffix,
    this.autofocus = false,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          autofocus: autofocus,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          enableSuggestions: true,
          autocorrect: false,
          enableIMEPersonalizedLearning: true,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.appColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            suffixIcon: suffix,
            filled: true,
            fillColor: context.appColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.appColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.appColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.appColors.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
