import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

InputDecoration appInputDecoration({String? hint}) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.cairo(color: const Color(0xFF6F6B7D), fontSize: 13),
    filled: true,
    fillColor: AppColors.inputBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: border(AppColors.inputBorder),
    enabledBorder: border(AppColors.inputBorder),
    focusedBorder: border(AppColors.pink),
    errorBorder: border(AppColors.error),
    focusedErrorBorder: border(AppColors.error),
    errorStyle: GoogleFonts.cairo(color: AppColors.error, fontSize: 12),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: AppColors.label,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.ltr = false,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;

  /// للحقول التي تحتوي روابط أو أرقامًا: يجعل اتجاه الكتابة من اليسار.
  final bool ltr;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          textDirection: ltr ? TextDirection.ltr : null,
          textAlign: ltr ? TextAlign.left : TextAlign.start,
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
          decoration: appInputDecoration(hint: hint).copyWith(counterText: ''),
        ),
      ],
    );
  }
}

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.validator,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          dropdownColor: AppColors.panel,
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
          decoration: appInputDecoration(hint: hint),
        ),
      ],
    );
  }
}

/// يضع الحقول في عمودين على الشاشات العريضة وعمود واحد على الهاتف.
class FieldGrid extends StatelessWidget {
  const FieldGrid({super.key, required this.children, this.breakpoint = 560});

  final List<Widget> children;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        final twoColumns = constraints.maxWidth >= breakpoint;
        final itemWidth =
            twoColumns ? (constraints.maxWidth - gap) / 2 : constraints.maxWidth;

        return Wrap(
          spacing: gap,
          runSpacing: 16,
          children: [
            for (final child in children)
              SizedBox(
                width: child is FullWidthField ? constraints.maxWidth : itemWidth,
                child: child,
              ),
          ],
        );
      },
    );
  }
}

/// يلفّ حقلًا ليأخذ عرض الصف كاملًا داخل [FieldGrid].
class FullWidthField extends StatelessWidget {
  const FullWidthField({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// رسالة حالة (نجاح/خطأ) تحت النماذج.
class StatusMessage extends StatelessWidget {
  const StatusMessage({super.key, required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Text(
        message,
        style: GoogleFonts.cairo(
          color: isError ? AppColors.error : AppColors.success,
          fontSize: 13,
          height: 1.7,
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF090909),
        disabledBackgroundColor: const Color(0x66FFFFFF),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      child: busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF090909),
              ),
            )
          : Text(label),
    );
  }
}
