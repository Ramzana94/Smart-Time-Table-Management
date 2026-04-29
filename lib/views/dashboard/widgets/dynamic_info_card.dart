import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_sizes.dart';
import 'package:smart_timetable_managment/core/constants/app_weight.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';

enum CardType { department, teacher }

class DynamicInfoCard extends StatelessWidget {
  final CardType type;
  final String title;
  final String subtitle;
  final String? description;
  final String? email;
  final String? phone;
  final String? extraInfo;
  final String classesText;
  final Widget? leadingIcon;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DynamicInfoCard({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.classesText,
    this.description,
    this.email,
    this.phone,
    this.extraInfo,
    this.leadingIcon,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE4F1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D16355C),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48.r,
                width: 48.r,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F0FB), Color(0xFFD7EAF4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child:
                      leadingIcon ??
                      CustomText(
                        text: title.isNotEmpty ? title[0].toUpperCase() : "",
                        fontWeight: AppWeights.bold,
                        color: AppColors.primary,
                        fontSize: AppSizes.s18,
                      ),
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: title,
                      fontSize: AppSizes.s16,
                      fontWeight: AppWeights.bold,
                      color: const Color(0xFF12284A),
                    ),
                    4.verticalSpace,
                    CustomText(
                      text: subtitle,
                      color: const Color(0xFF61748E),
                      fontSize: 13,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _ActionButton(
                    icon: AppIcons.edit,
                    onTap: onEdit,
                    foregroundColor: const Color(0xFF39597C),
                    backgroundColor: const Color(0xFFF0F5FB),
                  ),
                  8.horizontalSpace,
                  _ActionButton(
                    icon: AppIcons.delete,
                    onTap: onDelete,
                    foregroundColor: AppColors.red,
                    backgroundColor: const Color(0xFFFFF0F0),
                  ),
                ],
              ),
            ],
          ),
          14.verticalSpace,
          if (type == CardType.department && description != null)
            CustomText(
              text: description!.trim().isEmpty
                  ? 'No department description added yet.'
                  : description!,
              color: const Color(0xFF4E6784),
              fontSize: 13,
            ),
          if (type == CardType.teacher) ...[
            if (email != null && email!.trim().isNotEmpty)
              _InfoRow(icon: AppIcons.email, text: email!),
            if (phone != null && phone!.trim().isNotEmpty)
              _InfoRow(icon: Icons.phone_outlined, text: phone!),
            if (extraInfo != null && extraInfo!.trim().isNotEmpty)
              _InfoRow(
                icon: Icons.workspace_premium_outlined,
                text: extraInfo!,
              ),
            if ((email == null || email!.trim().isEmpty) &&
                (phone == null || phone!.trim().isEmpty) &&
                (extraInfo == null || extraInfo!.trim().isEmpty))
              const CustomText(
                text: 'No additional teacher details available yet.',
                color: Color(0xFF4E6784),
                fontSize: 13,
              ),
          ],
          14.verticalSpace,
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFE),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCE4F1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        AppIcons.menu_book_outlined,
                        size: AppSizes.s18,
                        color: Color(0xFF607792),
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: CustomText(
                          text: classesText,
                          color: const Color(0xFF38526F),
                          fontWeight: AppWeights.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color foregroundColor;
  final Color backgroundColor;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: foregroundColor, size: 18),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF61748E)),
          8.horizontalSpace,
          Expanded(
            child: CustomText(
              text: text,
              color: const Color(0xFF4E6784),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}