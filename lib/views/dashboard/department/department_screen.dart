import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';
import 'package:smart_timetable_managment/core/utils/app_dialogbox.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/dynamic_info_card.dart';


class DepartmentScreen extends StatelessWidget {
  const DepartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return Obx(() {
      if (!controller.isDepartmentsReady.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text("Syncing departments...")),
        );
      }

      final departments = controller.departments.toList(growable: false);

      if (departments.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text("No Departments Found")),
        );
      }

      return ListView.builder(
        itemCount: departments.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final department = departments[index];
          final classCount = controller.departmentClassCount(department);

          return DynamicInfoCard(
            type: CardType.department,
            title: department.depName,
            subtitle: department.depCode,
            description: department.description,
            classesText: '$classCount classes',
            onDelete: () {
               AppDialogs.showLogoutDialog(
                message: AppStrings.confirmDeleteDept,
                onConfirm: () {
                   controller.deleteDepartment(department.id);
                },
              );
             
            },
            onEdit: () {
              controller.openEditDepartmentSheet(department);
            },
          );
        },
      );
    });
  }
}