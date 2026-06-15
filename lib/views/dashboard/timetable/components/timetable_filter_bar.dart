// import 'package:flutter/material.dart';
// import 'package:smart_timetable_managment/core/constants/app_colors.dart';

// class TimetableFilterBar extends StatelessWidget {
//   final List<String> departmentOptions;
//   final List<String> semesterOptions;
//   final List<String> shiftOptions;
//   final String? selectedDepartment;
//   final String? selectedSemester;
//   final String? selectedShift;
//   final ValueChanged<String?> onDepartmentChanged;
//   final ValueChanged<String?> onSemesterChanged;
//   final ValueChanged<String?> onShiftChanged;

//   const TimetableFilterBar({
//     super.key,
//     required this.departmentOptions,
//     required this.semesterOptions,
//     required this.shiftOptions,
//     required this.selectedDepartment,
//     required this.selectedSemester,
//     required this.selectedShift,
//     required this.onDepartmentChanged,
//     required this.onSemesterChanged,
//     required this.onShiftChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 12,
//       runSpacing: 12,
//       children: [
//         _TimetableFilterField(
//           label: 'Department',
//           value: selectedDepartment,
//           options: departmentOptions,
//           onChanged: onDepartmentChanged,
//           icon: Icons.apartment_outlined,
//         ),
//         _TimetableFilterField(
//           label: 'Semester',
//           value: selectedSemester,
//           options: semesterOptions,
//           onChanged: onSemesterChanged,
//           icon: Icons.school_outlined,
//         ),
//         _TimetableFilterField(
//           label: 'Shift',
//           value: selectedShift,
//           options: shiftOptions,
//           onChanged: onShiftChanged,
//           icon: Icons.schedule_outlined,
//         ),
//       ],
//     );
//   }
// }

// class _TimetableFilterField extends StatelessWidget {
//   final String label;
//   final String? value;
//   final List<String> options;
//   final ValueChanged<String?> onChanged;
//   final IconData icon;

//   const _TimetableFilterField({
//     required this.label,
//     required this.value,
//     required this.options,
//     required this.onChanged,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ConstrainedBox(
//       constraints: const BoxConstraints(maxWidth: 240),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF42526B),
//             ),
//           ),
//           const SizedBox(height: 8),
//           DropdownButtonFormField<String>(
//             initialValue: value,
//             isExpanded: true,
//             selectedItemBuilder: (context) {
//               return options
//                   .map(
//                     (option) => Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         option,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   )
//                   .toList();
//             },
//             decoration: InputDecoration(
//               isDense: true,
//               filled: true,
//               fillColor: Colors.white,
//               prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
//               prefixIconConstraints: const BoxConstraints(
//                 minWidth: 36,
//                 maxWidth: 36,
//                 minHeight: 18,
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 12,
//                 vertical: 12,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: const BorderSide(color: Color(0xFFD8E1EF)),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: const BorderSide(color: Color(0xFFD8E1EF)),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16),
//                 borderSide: const BorderSide(
//                   color: AppColors.primary,
//                   width: 1.2,
//                 ),
//               ),
//             ),
//             dropdownColor: Colors.white,
//             icon: const Icon(Icons.keyboard_arrow_down_rounded),
//             items: options
//                 .map(
//                   (option) => DropdownMenuItem<String>(
//                     value: option,
//                     child: Text(
//                       option,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 )
//                 .toList(),
//             onChanged: options.isEmpty ? null : onChanged,
//           ),
//         ],
//       ),
//     );
//   }
// }