import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:smart_timetable_managment/widgets/app_text.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueNotifier<T?> valueListenable;
  final ValueChanged<T?> onChanged;

  final String hintText;
  final IconData? icon;

  final double? height;
  final double? width;
  final Color borderColor;
  final double maxDropDownHeight;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.valueListenable,
    required this.onChanged,
    required this.hintText,
    this.icon,
    this.height = 55,
    this.width = double.infinity,
    this.borderColor = Colors.grey,
    this.maxDropDownHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T?>(
      valueListenable: valueListenable,
      builder: (context, value, _) {
        return DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,

            valueListenable: valueListenable, 

            hint: Row(
              children: [
                Expanded(child: CustomText(text: hintText, fontSize: 12,)),
              ],
            ),

            items: items
                .map(
                  (item) => DropdownItem<T>(
                    value: item,
                    height: 40.h,
                    child: Text(itemLabel(item)),
                  ),
                )
                .toList(),

            onChanged: onChanged,

            buttonStyleData: ButtonStyleData(
              height: height,
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
            ),

            iconStyleData: const IconStyleData(
              icon: Icon(Icons.keyboard_arrow_down_outlined),
              // iconSize: 22,
              // iconEnabledColor: Colors.black,
            ),

            dropdownStyleData: DropdownStyleData(
              maxHeight: maxDropDownHeight.h,
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(10),
                // color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}