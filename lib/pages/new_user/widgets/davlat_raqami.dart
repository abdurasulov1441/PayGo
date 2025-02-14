import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taksi/style/app_colors.dart';

class DavlatRaqami extends StatefulWidget {
  final Function(String region, String letter, String number, String suffix)
      onChanged;

  const DavlatRaqami({super.key, required this.onChanged});

  @override
  _DavlatRaqamiState createState() => _DavlatRaqamiState();
}

class _DavlatRaqamiState extends State<DavlatRaqami> {
  final TextEditingController regionController = TextEditingController();
  final TextEditingController letterController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController suffixController = TextEditingController();

  final FocusNode regionFocus = FocusNode();
  final FocusNode letterFocus = FocusNode();
  final FocusNode numberFocus = FocusNode();
  final FocusNode suffixFocus = FocusNode();

  @override
  void dispose() {
    regionController.dispose();
    letterController.dispose();
    numberController.dispose();
    suffixController.dispose();
    regionFocus.dispose();
    letterFocus.dispose();
    numberFocus.dispose();
    suffixFocus.dispose();
    super.dispose();
  }

  void _updateValue() {
    widget.onChanged(
      regionController.text,
      letterController.text,
      numberController.text,
      suffixController.text,
    );
  }

  void _moveFocus(FocusNode currentFocus, FocusNode nextFocus, String value,
      int maxLength) {
    if (value.length == maxLength) {
      currentFocus.unfocus();
      FocusScope.of(context).requestFocus(nextFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width: 280,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textColor),
        color: AppColors.ui,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.black),
          const SizedBox(width: 5),

          // Регион (01)
          SizedBox(
            width: 30,
            child: TextField(
              controller: regionController,
              focusNode: regionFocus,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Number',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (value) {
                _updateValue();
                _moveFocus(regionFocus, letterFocus, value, 2);
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: "",
                hintText: "01",
              ),
            ),
          ),
          const SizedBox(width: 5),
          const VerticalDivider(
            color: Colors.black,
            width: 1,
            thickness: 1,
          ),
          const SizedBox(width: 5),

          // Первая буква (A)
          SizedBox(
            width: 25,
            child: TextField(
              controller: letterController,
              focusNode: letterFocus,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
                LengthLimitingTextInputFormatter(1),
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Number',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (value) {
                _updateValue();
                _moveFocus(letterFocus, numberFocus, value, 1);
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: "",
                hintText: "A",
              ),
            ),
          ),
          const SizedBox(width: 5),

          // Три цифры (711)
          SizedBox(
            width: 40,
            child: TextField(
              controller: numberController,
              focusNode: numberFocus,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Number',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (value) {
                _updateValue();
                _moveFocus(numberFocus, suffixFocus, value, 3);
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: "",
                hintText: "711",
              ),
            ),
          ),
          const SizedBox(width: 5),

          // Две буквы (EA)
          SizedBox(
            width: 35,
            child: TextField(
              controller: suffixController,
              focusNode: suffixFocus,
              textCapitalization: TextCapitalization.characters,
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z]')),
                LengthLimitingTextInputFormatter(2),
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Number',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (_) => _updateValue(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: "",
                hintText: "EA",
              ),
            ),
          ),

          const SizedBox(width: 5),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/flag_uz.png',
                width: 25,
                height: 15,
              ),
              Text(
                'UZ',
                style: TextStyle(
                  fontFamily: 'Number',
                  fontSize: 10,
                  color: AppColors.grade1,
                ),
              ),
            ],
          ),
          const Icon(Icons.circle, size: 8, color: Colors.black),
        ],
      ),
    );
  }
}
