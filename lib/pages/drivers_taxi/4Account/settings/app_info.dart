import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:taksi/services/style/app_colors.dart';
import 'package:taksi/services/style/app_style.dart';

class AppInfo extends StatefulWidget {
  @override
  _AppInfoState createState() => _AppInfoState();
}

class _AppInfoState extends State<AppInfo> {
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    _fetchAppInfo();
  }

  Future<void> _fetchAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.arrow_back, color: Colors.white)),
        title: Text("PayGo haqida", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.grade1,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            SvgPicture.asset(
              "assets/icons/paygo_logo.svg", // Logotip SVG formatda
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              "PayGo",
              style: AppStyle.fontStyle.copyWith(
                  color: AppColors.grade1,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text("Versiya: $_appVersion",
                style: AppStyle.fontStyle.copyWith(
                    color: AppColors.grade1,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text(
              "PayGo – bu qulay va tezkor yuk va taksi buyurtma qilish tizimi. Bizning platformamizda siz istalgan vaqtda taksi va yuk mashinaga buyurtma qilishingiz mumkin.",
              textAlign: TextAlign.center,
              style: AppStyle.fontStyle.copyWith(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.email, color: AppColors.grade1),
                SizedBox(width: 10),
                Text("support@paygo.app-center.uz",
                    style: AppStyle.fontStyle
                        .copyWith(fontSize: 16, color: Colors.black87)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, color: AppColors.grade1),
                SizedBox(width: 10),
                Text("+998 90 096 17 04",
                    style: AppStyle.fontStyle
                        .copyWith(fontSize: 16, color: Colors.black87)),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "Biz bilan bog'lanish uchun support@paygo.uz ga yozing")),
                );
              },
              child: Text("Biz bilan bog'laning",
                  style: AppStyle.fontStyle.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.grade1,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
