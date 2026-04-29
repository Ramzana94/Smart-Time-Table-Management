import 'package:flutter/material.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';

class CustomCard extends StatelessWidget {
  final Widget? child;
  final String title;
  final double height;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? value;
  final String? subtitle;
  final Color? accentColor;
  final Color? iconBackgroundColor;

  const CustomCard({
    super.key,
    this.height = 80,
    this.onTap,
    this.icon,
    this.child,
    required this.title,
    this.value,
    this.subtitle,
    this.accentColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final highlightColor = accentColor ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDCE4F1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F16355C),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: child ?? _buildContent(highlightColor),
      ),
    );
  }

  Widget _buildContent(Color highlightColor) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: (iconBackgroundColor ?? highlightColor).withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: highlightColor, size: AppSizes.s24),
              ),
              const Spacer(),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    fontSize: AppSizes.s24,
                    fontWeight: FontWeight.w700,
                    color: highlightColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF193252),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF61748E),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class CustomCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;

//   const CustomCard({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(10.w), // 🔥 responsive padding
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 6,
//             color: Colors.black12,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           /// 🔹 Top Row (FIXED)
//           Row(
//             children: [
//               Icon(icon, size: 18.sp), // 🔥 smaller icon
//               6.horizontalSpace,
//               Expanded( // 🔥 IMPORTANT (prevents overflow)
//                 child: Text(
//                   title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 11.sp, // 🔥 responsive text
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           6.verticalSpace,

//           /// 🔹 Value
//           FittedBox( // 🔥 prevents bottom overflow
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }