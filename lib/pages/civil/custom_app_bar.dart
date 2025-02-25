import 'package:flutter/material.dart';
import 'package:taksi/services/style/app_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Stack(children: [
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    IconButton(
                      icon: Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                    ),
                  ],
                ),
                SizedBox(
                  width: 20,
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
      ]),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(200);
}
