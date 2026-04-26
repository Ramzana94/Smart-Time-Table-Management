import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const CustomCard({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        height: 100.h, // 👈 same size for all cards
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: AppColors.primary),
            10.verticalSpace,
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: AppWeights.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}