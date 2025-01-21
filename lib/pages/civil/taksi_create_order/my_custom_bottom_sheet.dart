import 'package:flutter/material.dart';

class MyCustomBottomSheet {
  static void show(BuildContext context,
      {required List<dynamic> items,
      required Function(String) onItemSelected}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: ListView.builder(
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
        );
      },
    );
  }
}
