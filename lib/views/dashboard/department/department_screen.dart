import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_timetable_managment/controllers/admin_dashboard_controller.dart';
import 'package:smart_timetable_managment/views/dashboard/widgets/dynamic_info_card.dart';

class DepartmentScreen extends StatelessWidget {
 DepartmentScreen({super.key});
final controller = Get.find<AdminDashboardController>();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('departments')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No Departments Found"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];

            return DynamicInfoCard(
              type: CardType.department,
              title: doc['depName'],
              subtitle: doc['depCode'],
              description: doc['description'],
              classesText: "8 classes",
              onDelete: () {
                FirebaseFirestore.instance
                    .collection('departments')
                    .doc(doc.id)
                    .delete();
              },
              onEdit: (){
                controller.openEditDepartmentSheet(doc.id, doc.data());              },
            );
          },
        );
      },
    );
  }
}