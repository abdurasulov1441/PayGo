import 'package:flutter/material.dart';

class DropdownWidget extends StatelessWidget {
  final List<dynamic> items;
  final int? selectedValue;
  final String hintText;
  final ValueChanged<int?>? onChanged;

  const DropdownWidget({
    Key? key,
    required this.items,
    required this.selectedValue,
    required this.hintText,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
      value: selectedValue,
      items: items.map<DropdownMenuItem<int>>((item) {
        return DropdownMenuItem<int>(
          value: item['id'],
          child: Text(item['name']),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
