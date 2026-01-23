import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/theme.dart';

class LabeledDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final String Function(T)? shortLabelBuilder;
  final ValueChanged<T?> onChanged;
  final String? label;

  const LabeledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.labelBuilder,
    this.shortLabelBuilder,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.appColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: Icon(
                PhosphorIconsDuotone.caretDown,
                color: context.appColors.textSecondary,
              ),
              dropdownColor: context.appColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: context.appColors.textPrimary,
              ),
              onChanged: onChanged,
              selectedItemBuilder: shortLabelBuilder != null
                  ? (context) => items
                      .map((item) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              shortLabelBuilder!(item),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: context.appColors.textPrimary,
                              ),
                            ),
                          ))
                      .toList()
                  : null,
              items: items
                  .map((item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          labelBuilder(item),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
