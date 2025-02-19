import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taksi/services/style/app_colors.dart';

void showAttachmentSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Файл юклаш",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attachmentButton(
                    context, "Галерея", "assets/icons/gallery.svg", () async {
                  final image = await _pickImage(ImageSource.gallery);
                  if (image != null) {
                    // TODO: Файлни серверга юбориш ёки UI'да кўрсатиш
                  }
                }),
                _attachmentButton(context, "Камера", "assets/icons/camera.svg",
                    () async {
                  final image = await _pickImage(ImageSource.camera);
                  if (image != null) {
                    // TODO: Файлни серверга юбориш ёки UI'да кўрсатиш
                  }
                }),
                _attachmentButton(context, "Файл", "assets/icons/file.svg", () {
                  // TODO: Файл танлаш функцияси
                }),
                _attachmentButton(
                    context, "Геолокация", "assets/icons/location.svg", () {
                  // TODO: Геолокация юбориш функцияси
                }),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

/// Файл танлаш учун
Future<XFile?> _pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: source);
  return image;
}

Widget _attachmentButton(
    BuildContext context, String title, String iconPath, VoidCallback onTap) {
  return Column(
    children: [
      GestureDetector(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.grade1.withOpacity(0.1),
          child: SvgPicture.asset(iconPath, width: 30, color: AppColors.grade1),
        ),
      ),
      const SizedBox(height: 5),
      Text(title, style: const TextStyle(fontSize: 14)),
    ],
  );
}
