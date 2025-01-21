import 'package:flutter/material.dart';

class MyCustomBottomSheetForPeoples {
  static void show(BuildContext context,
      {required List<dynamic> items, required Function(String) onItemSelected}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
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
        );
      },
    );
  }
}

