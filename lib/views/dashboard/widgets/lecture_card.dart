import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';

class LectureCard extends StatelessWidget {
  final String title;
  final String dayTime;
  final String room;
  final String department;
  
  const LectureCard({
    super.key,
    required this.title,
    required this.dayTime,
    required this.room,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E6ED)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  Icon Box
          Container(
            height: 50,
            // width: 50,
            decoration: BoxDecoration(
              // color: const Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              AppIcons.book,
              color: Colors.deepPurple,
            ),
          ),

          14.horizontalSpace,

          // 📄 Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  overflow: TextOverflow.ellipsis,
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                6.verticalSpace,

                // Day & Time
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    6.horizontalSpace,
                    Text(dayTime),
                  ],
                ),

                6.verticalSpace,

                // Room
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16),
                    6.horizontalSpace,
                    Text(room),
                  ],
                ),

                8.verticalSpace,

                // Department
                Text(
                  overflow: TextOverflow.ellipsis,
                  department,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}