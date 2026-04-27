import 'package:flutter/material.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/models/timetable_model.dart';

class TimetableSessionCard extends StatelessWidget {
  final List<TimetableModel> entries;
  final bool canManage;
  final VoidCallback onTap;

  const TimetableSessionCard({
    super.key,
    required this.entries,
    required this.canManage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final entry = entries.first;
    final roomLabel = entry.room.trim().isEmpty ? entry.department : entry.room;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F6FE),
            borderRadius: BorderRadius.circular(22),
         border:Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 4
          )
         ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D1E3A5F),
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canManage || entries.length > 1)
                  Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      entries.length > 1
                          ? Icons.layers_outlined
                          : Icons.more_horiz_rounded,
                      size: 18,
                      color: const Color(0xFF6C7B92),
                    ),
                  ),
                Text(
                  entry.subject,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF12284A),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  entry.teacher,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF496483),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  roomLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (entries.length > 1) ...[
                  const SizedBox(height: 8),
                  Text(
                    '+${entries.length - 1} more',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6C7B92),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}