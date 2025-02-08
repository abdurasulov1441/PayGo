import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class MainCivilPage extends StatelessWidget {
  const MainCivilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ui,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/civil_main.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 150,
                        height: 150,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PayGo',
                        style: AppStyle.fontStyle.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Harakatlanish va yuk jo‘natish endi tez,',
                        style: AppStyle.fontStyle.copyWith(
                          fontSize: 13,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                      Text('qulay va xavfsiz!',
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 13,
                            color: Colors.white,
                          ))
                    ],
                  ),
                ],
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Sizga yaqin transportlar',
                      style: AppStyle.fontStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grade1),
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push(
                            Routes.nearTrucks,
                          );
                        },
                        child: transportCard(
                          'Yuk mashinalar',
                          'truck',
                          Colors.green,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(
                            Routes.nearCars,
                          );
                        },
                        child: transportCard(
                          'Yengi avto mashinalar',
                          'car',
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Buyurtma berish',
                      style: AppStyle.fontStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grade1),
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.push(
                            Routes.taxiPage,
                          );
                        },
                        child: transportCard(
                          'Yuk mashinalar',
                          'truck',
                          Colors.green,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(
                            Routes.taxiPage,
                          );
                        },
                        child: transportCard(
                          'Yengi avto mashinalar',
                          'car',
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget transportCard(String title, String icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 40,
            child: SvgPicture.asset(
              'assets/icons/$icon.svg',
              height: 30,
              width: 30,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppStyle.fontStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.uiText),
          ),
        ],
      ),
    );
  }
}
