// import 'package:flutter/material.dart';

// enum CardType { department, teacher }

// class DynamicInfoCard extends StatelessWidget {
//   final CardType type;

//   final String title;
//   final String? subtitle;
//   final String? description;

//   final String? email;
//   final String? phone;
//   final String? extraInfo;

//   final String classesText;

//   final Widget? leadingIcon;

//   final VoidCallback? onEdit;
//   final VoidCallback? onDelete;

//   const DynamicInfoCard({
//     super.key,
//     required this.type,
  
//      this.subtitle,
//     required this.classesText,
//     this.description,
//     this.email,
//     this.phone,
//     this.extraInfo,
//     this.leadingIcon,
//     this.onEdit,
//     this.onDelete, required this.title,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.blue.shade100),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 22,
//                 backgroundColor: Colors.blue.shade50,
//                 child: leadingIcon ??
//                     Text(
//                       title.isNotEmpty ? title[0].toUpperCase() : "",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                     ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       subtitle?? '',
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: onEdit,
//                     child: const Icon(Icons.edit, color: Colors.black54),
//                   ),
//                   const SizedBox(width: 10),
//                   GestureDetector(
//                     onTap: onDelete,
//                     child: const Icon(Icons.delete, color: Colors.red),
//                   ),
//                 ],
//               )
//             ],
//           ),

//           const SizedBox(height: 10),

//           if (type == CardType.department && description != null)
//             Text(
//               description!,
//               style: TextStyle(color: Colors.grey.shade700),
//             ),

//           if (type == CardType.teacher) ...[
//             if (email != null)
//               Text(email!, style: TextStyle(color: Colors.grey.shade700)),
//             if (phone != null)
//               Text(phone!, style: TextStyle(color: Colors.grey.shade700)),
//             if (extraInfo != null)
//               Text(extraInfo!,
//                   style: const TextStyle(fontStyle: FontStyle.italic)),
                  
//           ],

//           const SizedBox(height: 10),

//           Row(
//             children: [
//               const Icon(Icons.menu_book_outlined,
//                   size: 18, color: Colors.grey),
//               const SizedBox(width: 6),
//               Text(
//                 classesText,
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
enum CardType { department, teacher }
class DynamicInfoCard extends StatelessWidget {
  final CardType type;

  final String title;
  final String? subtitle;
  final String? specialization; // ✅ NEW
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
    this.subtitle,
    this.specialization, // ✅ NEW
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
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue.shade50,
                child: leadingIcon ??
                    Text(
                      title.isNotEmpty ? title[0].toUpperCase() : "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    /// ✅ NULL SAFE subtitle
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(Icons.edit, color: Colors.black54),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 10),

          if (type == CardType.department && description != null)
            Text(
              description!,
              style: TextStyle(color: Colors.grey.shade700),
            ),

          if (type == CardType.teacher) ...[
            if (email != null && email!.isNotEmpty)
              Text(email!, style: TextStyle(color: Colors.grey.shade700)),

            if (phone != null && phone!.isNotEmpty)
              Text(phone!, style: TextStyle(color: Colors.grey.shade700)),

            if (extraInfo != null && extraInfo!.isNotEmpty)
              Text(extraInfo!,
                  style: const TextStyle(fontStyle: FontStyle.italic)),

            /// ✅ NEW: Specialization (null safe)
            if (specialization != null && specialization!.isNotEmpty)
              Text(
                specialization!,
                style: const TextStyle(color: Colors.blueGrey),
              ),
          ],

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.menu_book_outlined,
                  size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                classesText,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}