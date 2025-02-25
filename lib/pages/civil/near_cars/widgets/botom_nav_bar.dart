import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:taksi/services/style/app_style.dart';

import '../../../../services/style/app_colors.dart';

void showModalBottomSheetUser(BuildContext context) {
  List<bool> seatSelections = [
    false,
    false,
    false,
    false,
  ];

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: 400,
            width: double.infinity,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.textColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Yo’lovchilar soni kiriting',
                    style: AppStyle.fontStyle.copyWith(
                      color: AppColors.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/seat.svg',
                            width: 50,
                            height: 50,
                          ),
                          Text(
                            'Haydovchi',
                            style: AppStyle.fontStyle.copyWith(
                              fontSize: 12,
                              color: AppColors.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          SvgPicture.asset(
                            seatSelections[0]
                                ? 'assets/icons/seat.svg'
                                : 'assets/icons/seat_off.svg',
                            width: 50,
                            height: 50,
                          ),
                          Checkbox(
                            activeColor: AppColors.grade1,
                            value: seatSelections[0],
                            onChanged: (bool? value) {
                              setState(() {
                                seatSelections[0] = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) {
                      return Column(
                        children: [
                          SvgPicture.asset(
                            seatSelections[index + 1]
                                ? 'assets/icons/seat.svg'
                                : 'assets/icons/seat_off.svg',
                            width: 50,
                            height: 50,
                          ),
                          Checkbox(
                            activeColor: AppColors.grade1,
                            value: seatSelections[index + 1],
                            onChanged: (bool? value) {
                              setState(() {
                                seatSelections[index + 1] = value!;
                              });
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: AppColors.grade1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          print("Выбранные места: $seatSelections");
                        },
                        child: Text(
                          'Saqlash',
                          style: AppStyle.fontStyle.copyWith(
                            color: AppColors.backgroundColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
