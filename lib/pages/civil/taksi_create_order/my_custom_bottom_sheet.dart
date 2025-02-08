import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class MyCustomBottomSheet {
  static void show(
    BuildContext context, {
    required List<dynamic> items,
    required Function(String) onItemSelected,
    bool isSearch = false,
  }) {
    showModalBottomSheet(
      backgroundColor: AppColors.ui,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return _BottomSheetContent(
          items: items,
          onItemSelected: onItemSelected,
          isSearch: isSearch,
        );
      },
    );
  }
}

class _BottomSheetContent extends StatefulWidget {
  final List<dynamic> items;
  final Function(String) onItemSelected;
  final bool isSearch;

  const _BottomSheetContent({
    required this.items,
    required this.onItemSelected,
    required this.isSearch,
  });

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<_BottomSheetContent> {
  String searchText = "";
  String? selectedItem;

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredItems = widget.items
        .where((item) =>
            item.toString().toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Yukni jo’natadigan joyni tanlang',
            style: AppStyle.fontStyle.copyWith(
              color: AppColors.grade1,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.isSearch) ...[
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Izlash...",
                  prefixIcon: Icon(Icons.search, color: AppColors.grade1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
            ),
            SizedBox(height: 10),
          ],
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView.separated(
              separatorBuilder: (context, index) => Container(),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item =
                    filteredItems[index]['name'] ?? filteredItems[index];
                final isSelected = item == selectedItem;

                return ListTile(
                  title: Text(
                    item,
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 18,
                      color: isSelected ? Colors.white : AppColors.textColor,
                    ),
                  ),
                  tileColor: isSelected ? AppColors.grade1 : Colors.transparent,
                  onTap: () {
                    setState(() {
                      selectedItem = item;
                    });
                    widget.onItemSelected(item);
                   context.pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
