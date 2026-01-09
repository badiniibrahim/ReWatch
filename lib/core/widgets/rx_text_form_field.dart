import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';

class RxTextFormField extends StatelessWidget {
  const RxTextFormField({
    super.key,
    required this.name,
    required this.controller,
    this.fieldKey,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onPressedSuffixIcon,
    this.validator,
    this.maxLines,
    this.maxLength,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autocorrect = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final Key? fieldKey;
  final String name;
  final TextEditingController controller;
  final AutovalidateMode autovalidateMode;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSubmitted;
  final void Function()? onTap;
  final void Function()? onPressedSuffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool obscureText;
  final bool autocorrect;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final isValid = true.obs;
    final isObscured = obscureText.obs;

    return Obx(
      () => FormBuilderTextField(
        name: name,
        key: fieldKey,
        autofocus: false,
        obscureText: isObscured.value,
        maxLines: maxLines ?? 1,
        maxLength: maxLength,
        controller: controller,
        autovalidateMode: autovalidateMode,
        validator: validator,
        keyboardType: keyboardType,
        autocorrect: autocorrect,
        textInputAction: textInputAction,
        style: const TextStyle(
          color: AppColors.kTextPrimary,
          fontSize: 16,
          fontFamily: 'Sora',
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.kPrimary, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          hintText: name,
          hintStyle: TextStyle(
            color: AppColors.kTextPrimary.withValues(alpha: 0.5),
            fontSize: 16,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w400,
          ),
          suffixIcon: obscureText
              ? Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      isObscured.value = !isObscured.value;
                    },
                    icon: Icon(
                      isObscured.value
                          ? FluentIcons.eye_off_24_regular
                          : FluentIcons.eye_24_regular,
                      color: AppColors.kTextPrimary.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              : (isValid.value
                    ? null
                    : Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FluentIcons.error_circle_24_filled,
                          color: Colors.red[400],
                          size: 20,
                        ),
                      )),
          errorStyle: TextStyle(
            color: Colors.red[400],
            fontSize: 14,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w400,
          ),
        ),
        onTap: onTap,
        onChanged: (String? value) {
          if (validator != null) {
            isValid.value = validator?.call(value) == null;
          }
          onChanged?.call(value);
        },
        onSubmitted: onSubmitted,
      ),
    );
  }
}
