import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/pages/new_user/widgets/davlat_raqami.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class EnterDetailInfo extends StatefulWidget {
  final int roleId;

  const EnterDetailInfo({super.key, required this.roleId});

  @override
  _EnterDetailInfoState createState() => _EnterDetailInfoState();
}

class _EnterDetailInfoState extends State<EnterDetailInfo> {
  final TextEditingController carNumberController = TextEditingController();
  List<dynamic> carBrands = [];
  List<dynamic> carModels = [];
  List<dynamic> regions = [];
  int? selectedCarBrandId;
  int? selectedCarModelId;
  int? selectedFromRegionId;
  int? selectedToRegionId;
  bool isLoadingBrands = true;
  bool isLoadingModels = false;
  bool isLoadingRegions = true;

  @override
  void initState() {
    super.initState();
    fetchCarBrands();
    fetchRegions();
  }

  Future<void> fetchCarBrands() async {
    try {
      final response = await requestHelper
          .getWithAuth('/services/zyber/api/ref/get-car-brands');
      setState(() {
        carBrands = response;
        isLoadingBrands = false;
      });
    } catch (e) {}
  }

  Future<void> fetchCarModels(int brandId) async {
    setState(() => isLoadingModels = true);
    try {
      final response = await requestHelper.getWithAuth(
          '/services/zyber/api/ref/get-car-models?brand_id=$brandId');
      setState(() {
        carModels = response;
        isLoadingModels = false;
      });
    } catch (e) {}
  }

  Future<void> fetchRegions() async {
    try {
      final response = await requestHelper
          .getWithAuth('/services/zyber/api/ref/get-regions');
      setState(() {
        regions = response;
        isLoadingRegions = false;
      });
    } catch (e) {}
  }

  bool isFormValid() {
    return selectedCarBrandId != null &&
        selectedCarModelId != null &&
        carNumberController.text.isNotEmpty &&
        selectedFromRegionId != null &&
        selectedToRegionId != null &&
        selectedFromRegionId != selectedToRegionId;
  }

  void showSelectionSheet(
      List<dynamic> items, String title, Function(int) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(items[index]['name']),
                  onTap: () {
                    onSelect(items[index]['id']);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateCarNumber(
      String region, String letter, String number, String suffix) {
    setState(() {
      carNumberController.text = "$region$letter$number$suffix";
    });
  }

  Future<void> sendData() async {
    if (!isFormValid()) return;

    try {
      await requestHelper.putWithAuth(
          '/services/zyber/api/users/update-user-role',
          {'role_id': widget.roleId});
      final response = await requestHelper.postWithAuth(
        '/services/zyber/api/users/add-vehicle',
        {
          'brand_id': selectedCarBrandId,
          'model_id': selectedCarModelId,
          'plate_number': carNumberController.text.trim(),
          'from_location': selectedFromRegionId,
          'to_location': selectedToRegionId,
        },
      );
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'succes_send'.tr())));
        if (widget.roleId == 2) {
          router.go(Routes.taxiDriverPage);
        } else if (widget.roleId == 3) {
          router.go(Routes.truckDriverPage);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Ошибка отправки.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('error_conection'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.grade1,
          title: Text('enter_data'.tr(),
              style: AppStyle.fontStyle
                  .copyWith(color: Colors.white, fontSize: 20))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ui,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoadingBrands
                      ? null
                      : () => showSelectionSheet(
                              carBrands, 'select_car_brand'.tr(), (id) {
                            setState(() {
                              selectedCarBrandId = id;
                              selectedCarModelId = null;
                              carModels = [];
                            });
                            fetchCarModels(id);
                          }),
                  child: Text(
                    selectedCarBrandId == null
                        ? 'select_car_brand'.tr()
                        : carBrands.firstWhere((brand) =>
                            brand['id'] == selectedCarBrandId)['name'],
                    style: AppStyle.fontStyle.copyWith(color: AppColors.uiText),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ui,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoadingModels
                      ? null
                      : () => showSelectionSheet(
                              carModels, 'select_car_model'.tr(), (id) {
                            setState(() {
                              selectedCarModelId = id;
                            });
                          }),
                  child: Text(
                    selectedCarModelId == null
                        ? 'select_car_model'.tr()
                        : carModels.firstWhere((model) =>
                            model['id'] == selectedCarModelId)['name'],
                    style: AppStyle.fontStyle.copyWith(color: AppColors.uiText),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DavlatRaqami(
                onChanged: _updateCarNumber,
              ),
              const SizedBox(height: 20),
              Container(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ui,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoadingRegions
                      ? null
                      : () => showSelectionSheet(
                              regions, 'select_from_location'.tr(), (id) {
                            setState(() {
                              selectedFromRegionId = id;
                            });
                          }),
                  child: Text(
                    selectedFromRegionId == null
                        ? 'select_from_location'.tr()
                        : regions.firstWhere((region) =>
                            region['id'] == selectedFromRegionId)['name'],
                    style: AppStyle.fontStyle.copyWith(color: AppColors.uiText),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ui,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoadingRegions
                        ? null
                        : () => showSelectionSheet(
                                regions, 'select_to_location'.tr(), (id) {
                              setState(() {
                                selectedToRegionId = id;
                              });
                            }),
                    child: Text(
                      selectedToRegionId == null
                          ? 'select_to_location'.tr()
                          : regions.firstWhere((region) =>
                              region['id'] == selectedToRegionId)['name'],
                      style:
                          AppStyle.fontStyle.copyWith(color: AppColors.uiText),
                    )),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.grade1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isFormValid() ? sendData : null,
                  child: Text('send'.tr(),
                      style: AppStyle.fontStyle.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
