import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final BorderRadius? borderRadius;
  final bool? obsecureText;
  final Icon? prefixIcon;
  final Icon? sufixIcon;
  final String? Function(String?)? validator;
  final RxBool? isVisible;
  final VoidCallback? onToggle;
  final int? maxLines;
  final double? hintSize;
  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.borderRadius,
    this.obsecureText,
    this.prefixIcon,
    this.sufixIcon,
    this.validator,
    this.isVisible,
    this.onToggle,
    this.maxLines,
    this.hintSize,
  });
  @override
  Widget build(BuildContext context) {
    if (isVisible != null) {
      return Obx(
        () => TextFormField(
          obscureText: !(isVisible?.value ?? false),
          controller: controller,
          maxLines: 1,
          validator: validator,
          decoration: InputDecoration(
            hintStyle: TextStyle(fontSize: 12.sp),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.grey, width: 1.w),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.grey),
            ),
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                (isVisible?.value ?? false)
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          obscuringCharacter: '*',
        ),
      );
    } else {
      return TextFormField(
        maxLines: maxLines ?? 1,
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontSize: 12.sp),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.grey, width: 1.w),
          ),
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: sufixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}