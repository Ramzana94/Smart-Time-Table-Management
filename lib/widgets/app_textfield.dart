// import 'package:flutter/material.dart';
// import 'package:get/state_manager.dart';
// import 'package:smart_timetable_managment/core/constants/app_colors.dart';

// class CustomTextFormField extends StatelessWidget {
//   final String hintText;
//   final Icon? prefixIcon;
//   final Icon? suffixIcon;
//   final TextEditingController controller;
//   final bool? obscureText;
//   final RxBool? isVisible;
//   final String? labelText;
//   final int? maxLines;
//   final BorderRadius borderRadius;
//   final String? Function(String?)? validator;
//   final VoidCallback? onToggle;
//   final VoidCallback? onPressed;
//   const CustomTextFormField({
//     super.key,
//     required this.hintText,
//     required this.controller,
//    this.obscureText,
//     this.validator,
    
//    this.prefixIcon, this.suffixIcon, this.isVisible, this.onToggle, this.onPressed, required this.borderRadius, this.labelText, this.maxLines,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if( isVisible != null){
// return Obx(() => TextFormField(
//   obscureText: !(isVisible?.value??false),
//   validator: validator,
//   controller: controller,
//   // maxLines: maxLines,
//   maxLines: obscureText == true ? 1 : maxLines,
//       decoration: InputDecoration(
//         hintText: hintText,
//         prefixIcon: prefixIcon,
//         suffixIcon: IconButton(onPressed: onToggle, icon: 
//        (isVisible?.value?? false)
//        ? Icon(Icons.visibility)
//        : Icon(Icons.visibility_off)
//         ),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: AppColors.grey),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: AppColors.primary),
//         ),
//       ),
//       obscuringCharacter: '*',
//     )) ;

//     } 
//     else{
//       return
//       TextFormField(
//           validator: validator,
//           controller: controller,
//       decoration: InputDecoration(
//         hintText: hintText,
//         prefixIcon: prefixIcon,
//       suffixIcon: suffixIcon,
//         suffix: suffixIcon,
//         labelText: labelText,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: AppColors.grey),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: AppColors.primary),
//         ),
//       ),
//     );
//     }
//   }
// }



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final TextEditingController controller;
  final bool? obscureText;
  final RxBool? isVisible;
  final String? labelText;
  final int? maxLines;
  final BorderRadius? borderRadius;
  final String? Function(String?)? validator;
  final VoidCallback? onToggle;
  final VoidCallback? onPressed;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.isVisible,
    this.onToggle,
    this.onPressed,
    this.borderRadius,
    this.labelText,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final bool isObscure = obscureText == true;

    // 🔥 Error fix: obscure field always single line
    final int effectiveMaxLines = isObscure ? 1 : (maxLines ?? 1);

    // ✅ Common hint style
    const TextStyle hintTextStyle = TextStyle(
      color: AppColors.grey,
      fontSize: 12,
    );

    if (isVisible != null) {
      return Obx(
        () => TextFormField(
          controller: controller,
          validator: validator,
          obscureText: !(isVisible?.value ?? false),
          maxLines: effectiveMaxLines,
          obscuringCharacter: '*',
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintTextStyle,
            labelText: labelText,
            prefixIcon: prefixIcon,
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: (isVisible?.value ?? false)
                  ? const Icon(Icons.visibility)
                  : const Icon(Icons.visibility_off),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      );
    } else {
      return TextFormField(
        controller: controller,
        validator: validator,
        obscureText: isObscure,
        maxLines: effectiveMaxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintTextStyle,
          labelText: labelText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      );
    }
  }
}