import 'package:easy_localization/easy_localization.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/pages/civil/taksi_create_order/botom_shet_for_peoples.dart';
import 'package:taksi/pages/civil/taksi_create_order/my_custom_bottom_sheet.dart';
import 'package:taksi/pages/civil/taksi_create_order/my_custom_button.dart';
import 'package:taksi/pages/civil/taksi_create_order/my_custom_text_field.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TaxiPage extends StatefulWidget {
  const TaxiPage({super.key});

  @override
  _TaxiPageState createState() => _TaxiPageState();
}

class _TaxiPageState extends State<TaxiPage> {
  List<dynamic> regions = [];
  List<dynamic> times = [];
  String? selectedFromRegion;
  String? selectedToRegion;
  String? selectedTime;
  int? selectedPeople;
  bool isCustomPeople = false;
  final TextEditingController _peopleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRegions();
    fetchTimes();
  }

  Future<void> createOrderTaxi() async {
    try {
      final response = await requestHelper.postWithAuth(
          '/services/zyber/api/orders/make-taxi-order',
          {
            "from_location": 12,
            "to_location": 9,
            "passenger_count": 2,
            "pochta": "Pochta bor Quqonga",
            "time_id": 1
          },
          log: true);
      if (response['status'] == 'success') {
        ElegantNotification.success(
          width: 360,
          isDismissable: false,
          animationCurve: Curves.easeInOut,
          position: Alignment.topCenter,
          animation: AnimationType.fromTop,
          description: Text('succes'.tr()),
          onDismiss: () {},
          onNotificationPressed: () {},
          shadow: BoxShadow(
            color: Colors.green,
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ).show(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [Text('error'.tr()), Text(" $e")],
          ),
        ),
      );
    }
  }

  Future<void> fetchRegions() async {
    try {
      final response = await requestHelper.getWithAuth(
        '/services/zyber/api/ref/get-regions',
      );
      setState(() {
        regions = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [Text('error'.tr()), Text(" $e")],
          ),
        ),
      );
    }
  }

  Future<void> fetchTimes() async {
    try {
      final response = await requestHelper.getWithAuth(
        '/services/zyber/api/ref/get-times',
        log: true,
      );
      setState(() {
        times = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [Text('error'.tr()), Text(" $e")],
          ),
        ),
      );
    }
  }

  void showRegionPicker(String title, bool isFromRegion) {
    MyCustomBottomSheet.show(
      context,
      items: regions,
      onItemSelected: (region) {
        setState(() {
          if (isFromRegion) {
            selectedFromRegion = region;
          } else {
            selectedToRegion = region;
          }
        });
      },
    );
  }

  void showTimePicker() {
    MyCustomBottomSheet.show(
      context,
      items: times,
      onItemSelected: (time) {
        setState(() {
          selectedTime = time;
        });
      },
    );
  }

  void showPeoplePicker() {
    MyCustomBottomSheetForPeoples.show(
      context,
      items: List.generate(4, (index) => '${index + 1} odam'),
      onItemSelected: (peopleCount) {
        setState(() {
          selectedPeople = int.tryParse(peopleCount.split(' ')[0]);
          isCustomPeople = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ui,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.backgroundColor,
            )),
        backgroundColor: AppColors.grade1,
        title: Text(
          'TEST',
          style: AppStyle.fontStyle
              .copyWith(fontSize: 20, color: AppColors.backgroundColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyCustomButton(
              onPressed: regions.isNotEmpty
                  ? () => showRegionPicker('Qayerdan', true)
                  : null,
              text: selectedFromRegion ?? 'Qayerdan tanlang',
            ),
            const SizedBox(height: 20),
            MyCustomButton(
              onPressed: regions.isNotEmpty
                  ? () => showRegionPicker('Qayerga', false)
                  : null,
              text: selectedToRegion ?? 'Qayerga tanlang',
            ),
            const SizedBox(height: 20),
            MyCustomButton(
              onPressed: times.isNotEmpty ? () => showTimePicker() : null,
              text: selectedTime ?? 'Vaqtni tanlang',
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              activeColor: AppColors.grade1,
              inactiveThumbColor: AppColors.grade1,
              inactiveTrackColor: AppColors.ui,
              title: const Text('Pochta berib yuborish'),
              value: isCustomPeople,
              onChanged: (value) {
                setState(() {
                  isCustomPeople = value;
                  if (!value) {
                    _peopleController.clear();
                  }
                });
              },
            ),
            SizedBox(
              height: 10,
            ),
            if (!isCustomPeople)
              MyCustomButton(
                onPressed: () => showPeoplePicker(),
                text: selectedPeople != null
                    ? '$selectedPeople odam tanlangan'
                    : 'Odamlar sonini tanlang',
              )
            else
              MyCustomTextField(
                controller: _peopleController,
                hintText: 'Buyum nomini yozing',
              ),
            const SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.backgroundColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  createOrderTaxi();
                },
                child: Text('Buyurtma berish'))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _peopleController.dispose();
    super.dispose();
  }
}
