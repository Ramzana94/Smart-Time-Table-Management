import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/dynamic_info_card.dart';

class TeacherScreen extends StatelessWidget {
  const TeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return Obx(() {
      if (!controller.isTeachersReady.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text("Syncing teachers...")),
        );
      }

      final teachers = controller.teachers.toList(growable: false);

      if (teachers.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text("No Teachers Found")),
        );
      }

      return ListView.builder(
        itemCount: teachers.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final teacher = teachers[index];
          final classCount = controller.teacherClassCount(teacher);

          return DynamicInfoCard(
            type: CardType.teacher,
            title: teacher.teacherName,
            subtitle: teacher.teacherDept,
            email: teacher.teacherEmail,
            phone: teacher.teacherPhoneNo,
            extraInfo: teacher.teacherSpecialization,
            classesText: '$classCount classes',
            onDelete: () {
              controller.deleteTeacher(teacher.uid);
            },
            onEdit: () {
              controller.openEditTeacherSheet(teacher);
            },
          );
        },
      );
    });
  }
}