import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
class CustomMaterialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final double? minWidth;
  final double height;
  final bool? isLoading;
  final String? imagePath;
  final Color? borderColor;
  final double borderWidth;
  final Widget? child;
final Icon? icon;
final Color? loaderColor;
  const CustomMaterialButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.color,
   required this.borderRadius,
    this.minWidth,
  required this.height,
    required this.textColor,
    this.imagePath,
    this.borderColor,
    this.borderWidth = 1,
    this.isLoading = false,
    this.child, this.icon, this.loaderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      
      child: MaterialButton(
        onPressed: () {
          if (isLoading == true) return;
          onPressed();
        },
        color: color,
        minWidth: minWidth,
        height: height,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: borderWidth)
              : BorderSide.none,
        ),

        child: isLoading == true
            ? SizedBox(
                height: 22.h,
                width: 22.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3.w,
                  valueColor: AlwaysStoppedAnimation<Color>(loaderColor?? AppColors.white),
                ),
              )
            : (child ??
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (imagePath != null)
                        Image.asset(imagePath!, height: 20.h, width: 20.w),
                      if (imagePath != null) const SizedBox(width: 10),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: AppSizes.s16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if(icon !=null)
                      SizedBox(width: 10,),
                       if(icon!=null)...[
                        icon!,
                        // const SizedBox(width: 10,)
                      ],
                    ],
                  )),
      ),
    );
  }
}