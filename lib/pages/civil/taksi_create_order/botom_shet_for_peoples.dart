import 'package:flutter/material.dart';
import 'package:taksi/style/app_colors.dart';

class MyCustomBottomSheetForPeoples {
  static void show(BuildContext context,
      {required List<dynamic> items,
      required Function(String) onItemSelected}) {
    showModalBottomSheet(
      backgroundColor: AppColors.ui,
      context: context,
      builder: (context) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 90,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.grade1,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  height: 2,
                  indent: 10,
                  endIndent: 10,
                  color: const Color.fromARGB(255, 180, 180, 180),
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index].toString();
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      onItemSelected(item);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
