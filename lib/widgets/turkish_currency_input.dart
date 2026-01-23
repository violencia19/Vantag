import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../utils/currency_utils.dart';

// Re-export currency utils for backward compatibility
export '../utils/currency_utils.dart';

/// Türkçe para girişi için hazır TextField widget'ı
class TurkishCurrencyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final FocusNode? focusNode;
  final ValueChanged<double?>? onChanged;
  final VoidCallback? onEditingComplete;
  final InputDecoration? decoration;
  final bool allowDecimals;
  final int maxIntegerDigits;

  const TurkishCurrencyTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.focusNode,
    this.onChanged,
    this.onEditingComplete,
    this.decoration,
    this.allowDecimals = true,
    this.maxIntegerDigits = 12, // Trilyonlara kadar
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        PremiumCurrencyFormatter(
          allowDecimals: allowDecimals,
          maxIntegerDigits: maxIntegerDigits,
        ),
      ],
      decoration:
          decoration ??
          InputDecoration(labelText: label, hintText: hint ?? 'Tutar (₺)'),
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(parseAmount(value));
        }
      },
      onEditingComplete: onEditingComplete,
    );
  }
}

/// Premium gelir/gider girişi için özelleştirilmiş widget
class PremiumAmountInput extends StatefulWidget {
  final TextEditingController? controller;
  final double? initialValue;
  final String label;
  final String? hint;
  final String? prefix;
  final String? suffix;
  final bool showCurrency;
  final ValueChanged<double?>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final FocusNode? focusNode;
  final Color? accentColor;

  const PremiumAmountInput({
    super.key,
    this.controller,
    this.initialValue,
    required this.label,
    this.hint,
    this.prefix,
    this.suffix, // Will use CurrencyProvider if null
    this.showCurrency = true,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.accentColor,
  });

  @override
  State<PremiumAmountInput> createState() => _PremiumAmountInputState();
}

class _PremiumAmountInputState extends State<PremiumAmountInput> {
  late TextEditingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;

      if (widget.initialValue != null && widget.initialValue! > 0) {
        _controller.text = formatTurkishCurrency(
          widget.initialValue!,
          decimalDigits: 0,
          showDecimals: false,
        );
      }
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = widget.accentColor ?? theme.colorScheme.primary;
    final currencyProvider = context.watch<CurrencyProvider>();
    final suffixText = widget.suffix ?? currencyProvider.code;

    return TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        PremiumCurrencyFormatter(maxIntegerDigits: 12, allowDecimals: true),
      ],
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: widget.enabled ? null : theme.disabledColor,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint ?? '0',
        prefixText: widget.prefix,
        suffixText: widget.showCurrency ? suffixText : null,
        suffixStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: accentColor.withValues(alpha: 0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        filled: true,
        fillColor: accentColor.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      onChanged: (value) {
        widget.onChanged?.call(parseAmount(value));
      },
      validator: widget.validator,
    );
  }
}
