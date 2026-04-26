import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/dynamic_info_card.dart';

class TeacherScreen extends StatelessWidget {
  TeacherScreen({super.key});
 final controller = Get.find<AdminDashboardController>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('teachers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No Teachers Found"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];

            return DynamicInfoCard(
              type: CardType.teacher,
              title: doc['teacherName'] ?? '',
              subtitle: doc['teacherDept'] ?? '',
              email: doc['teacherEmail'] ?? '',
              phone: doc['teacherPhoneNo'] ?? '',
              extraInfo: doc['teacherSpecialization'] ?? '',
              classesText: "2 classes",
              onDelete: () {
                FirebaseFirestore.instance
                    .collection('teachers')
                    .doc(doc.id)
                    .delete();
              },
              onEdit: () {
                 controller.openEditTeacherSheet(doc.id, doc.data());
              },
            );
          },
        );
      },
    );
  }
}