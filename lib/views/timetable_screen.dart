

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/controllers/navigation_controller.dart';
import 'package:smart_timetable_managment/controllers/timetable_controller.dart';
import 'package:smart_timetable_managment/core/constants/app_colors.dart';
import 'package:smart_timetable_managment/core/constants/app_icons.dart';
import 'package:smart_timetable_managment/core/constants/app_strings.dart';


class TimeTableScreen extends StatelessWidget {
  TimeTableScreen({super.key});

  final navCtrl = Get.find<NavigationController>();
  final adminCtrl = Get.find<AdminDashboardController>();
  final timetableCtrl = Get.put(TimetableController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: StreamBuilder<QuerySnapshot>(
            stream: timetableCtrl.getTimetable(),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No Timetable Found"));
              }

              final docs = snapshot.data!.docs;

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final data =
                      docs[index].data() as Map<String, dynamic>;
                  final id = docs[index].id;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),

                      title: Text(
                        data["subject"] ?? "No Subject",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "Day: ${data["day"] ?? ""}\n"
                          "Time: ${data["time"] ?? ""}\n"
                          "Teacher: ${data["teacher"] ?? ""}\n"
                          "Room: ${data["room"] ?? ""}",
                        ),
                      ),

                      isThreeLine: true,

                      trailing: Obx(() {
                        final role = navCtrl.userRole.value.trim();

                        if (role == "Admin") {
                          return IconButton(
                            icon: const Icon(
                              AppIcons.delete,
                              color: AppColors.red,
                            ),
                            onPressed: () {
                              Get.defaultDialog(
                                title: AppStrings.delete,
                                middleText:
                                    AppStrings.sureToDeleteTimetable,
                                textCancel: AppStrings.no,
                                textConfirm:AppStrings.yes,
                                confirmTextColor: Colors.white,
                                
                                onConfirm: () {
                                  timetableCtrl.deleteTimetable(id);
                                  Get.back();
                                },
                              );
                            },
                          );
                        }

                        return const SizedBox.shrink();
                      }),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),

      // 🔥 FAB
      floatingActionButton: Obx(() {
        final role = navCtrl.userRole.value.trim();

        if (role == 'Admin') {
          return FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: AppColors.primary,
            onPressed: () {
              adminCtrl.openCreateBottomSheet();
            },
            child: const Icon(Icons.add, color: Colors.white),
          );
        }

        if (role == 'Teacher') {
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            onPressed: () {
              Get.snackbar("Teacher", "Edit Timetable feature");
            },
            icon: const Icon(Icons.edit),
            label: const Text("Edit"),
          );
        }

        return const SizedBox.shrink();
      }),
    );
  }
}