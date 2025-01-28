import 'package:flutter/material.dart';
import 'package:taksi/style/app_colors.dart';

class MyCustomBottomSheet {
  static void show(BuildContext context,
      {required List<dynamic> items,
      required Function(String) onItemSelected}) {
    showModalBottomSheet(
      backgroundColor: AppColors.ui,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.only(
      //     topLeft: Radius.circular(20),
      //     topRight: Radius.circular(20),
      //   ),
      // ),
      context: context,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.ui,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          // padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.grade1,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 90,
                height: 10,
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
                    final item = items[index]['name'] ?? items[index];
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
          ),
        );
      },
    );
  }
}
