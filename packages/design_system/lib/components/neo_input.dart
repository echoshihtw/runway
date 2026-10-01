import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_text_styles.dart';

enum NeoInputType { text, numeric, decimal, name, note }

class NeoInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final NeoInputType inputType;
  final int? maxLength;

  const NeoInput({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.hint,
    this.keyboardType,
    this.onChanged,
    this.inputType = NeoInputType.text,
    this.maxLength,
  });

  /// Numbers are set in the mono face, words in the label face, so a typed
  /// figure matches the ones printed beside it.
  TextStyle get _fieldStyle => switch (inputType) {
    NeoInputType.numeric || NeoInputType.decimal => AppTextStyles.metricSmall,
    NeoInputType.name ||
    NeoInputType.note ||
    NeoInputType.text => AppTextStyles.body,
  };

  List<TextInputFormatter> get _formatters {
    switch (inputType) {
      case NeoInputType.numeric:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxLength ?? 15),
        ];
      case NeoInputType.decimal:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          LengthLimitingTextInputFormatter(maxLength ?? 15),
        ];
      // No allow-list on the fields that hold words: six of the seven locales
      // are not ASCII. Nothing downstream needs the restriction.
      case NeoInputType.name:
        return [LengthLimitingTextInputFormatter(maxLength ?? 50)];
      case NeoInputType.note:
        return [LengthLimitingTextInputFormatter(maxLength ?? 200)];
      case NeoInputType.text:
        return [LengthLimitingTextInputFormatter(maxLength ?? 100)];
    }
  }

  TextInputType get _keyboardType {
    if (keyboardType != null) return keyboardType!;
    switch (inputType) {
      case NeoInputType.numeric:
        return TextInputType.number;
      case NeoInputType.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: _keyboardType,
          inputFormatters: _formatters,
          onChanged: onChanged,
          style: _fieldStyle,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: _fieldStyle.copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surfaceHigh,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.neonGreen,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
          ),
        ),
      ],
    );
  }
}
