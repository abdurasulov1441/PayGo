import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/pages/civil/taksi_create_order/botom_shet_for_peoples.dart';
import 'package:taksi/pages/civil/taksi_create_order/my_button_send.dart';
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
  bool isCustomPeople = true;

  int value = 0;
  int? nullableValue;
  bool positive = false;
  bool loading = false;

  final TextEditingController _peopleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRegions();
    fetchTimes();
  }

  Future<void> createOrderTaxi() async {
    if (selectedFromRegion == null ||
        selectedToRegion == null ||
        selectedTime == null ||
        (!isCustomPeople && selectedPeople == null)) {
      print('Please fill all fields');
      return;
    }

    try {
      final response = await requestHelper.postWithAuth(
        '/services/zyber/api/orders/make-taxi-order',
        {
          "from_location": regions.firstWhere(
              (element) => element['name'] == selectedFromRegion)['id'],
          "to_location": regions.firstWhere(
              (element) => element['name'] == selectedToRegion)['id'],
          "passenger_count": isCustomPeople
              ? int.tryParse(_peopleController.text) ?? 0
              : selectedPeople,
          "pochta": isCustomPeople ? _peopleController.text : null,
          "time_id": times
              .firstWhere((element) => element['name'] == selectedTime)['id'],
        },
        log: false,
      );

      if (response['status'] == 'success') {
        print('Order created');
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [Text('Xatolik yuz berdi:'), Text(" $e")],
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
        log: false,
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
      isSearch: true,
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
          ),
        ),
        backgroundColor: AppColors.grade1,
        title: Text(
          'Taksi buyurtma qilish',
          style: AppStyle.fontStyle.copyWith(
            fontSize: 20,
            color: AppColors.backgroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.backgroundColor,
                ),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyCustomButton(
                      labelIcon: 'location',
                      onPressed: regions.isNotEmpty
                          ? () => showRegionPicker('Qayerdan', true)
                          : null,
                      text: selectedFromRegion ?? 'Qayerdan',
                      isDropdown: true,
                    ),
                    const SizedBox(height: 20),
                    MyCustomButton(
                      isDropdown: true,
                      labelIcon: 'location',
                      onPressed: regions.isNotEmpty
                          ? () => showRegionPicker('Qayerga', false)
                          : null,
                      text: selectedToRegion ?? 'Qayerga',
                    ),
                    const SizedBox(height: 20),
                    MyCustomButton(
                      isDropdown: false,
                      onPressed:
                          times.isNotEmpty ? () => showTimePicker() : null,
                      text: selectedTime ?? 'Vaqtni tanlang',
                      labelIcon: 'time',
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedToggleSwitch.size(
                        iconList: [
                          Text(
                            'Pochta jo\'natish',
                            style: AppStyle.fontStyle.copyWith(
                                fontSize: 12,
                                color: value == 0
                                    ? AppColors.backgroundColor
                                    : AppColors.textColor),
                          ),
                          Text(
                            'Yo\'lovchi tashish',
                            style: AppStyle.fontStyle.copyWith(
                                fontSize: 12,
                                color: value == 1
                                    ? AppColors.backgroundColor
                                    : AppColors.textColor),
                          ),
                        ],
                        current: value,
                        values: const [0, 1],
                        iconOpacity: 0.2,
                        indicatorSize: const Size.fromWidth(400),
                        style: ToggleStyle(
                          indicatorColor: AppColors.grade1,
                          backgroundColor: AppColors.ui,
                          borderColor: AppColors.ui,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1.5),
                            ),
                          ],
                        ),
                        onChanged: (v) {
                          setState(() {
                            isCustomPeople = v == 0;
                            if (!isCustomPeople) {
                              _peopleController.clear();
                            }
                            value = v;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!isCustomPeople)
                      MyCustomButton(
                        isDropdown: false,
                        onPressed: () => showPeoplePicker(),
                        text: selectedPeople != null
                            ? '$selectedPeople odam tanlandi'
                            : 'Odamlar sonini tanlang',
                        labelIcon: 'peoples',
                      )
                    else
                      MyCustomTextField(
                        controller: _peopleController,
                        hintText: 'Buyum nomini yozing',
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: MyCustomButtonForSend(
              onPressed: () => createOrderTaxi(),
              text: ' Buyurtma berish',
              icon: null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _peopleController.dispose();
    super.dispose();
  }
}
