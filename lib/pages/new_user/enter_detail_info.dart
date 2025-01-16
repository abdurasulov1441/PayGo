import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/services/request_helper.dart';

class EnterDetailInfo extends StatefulWidget {
  final int roleId;

  const EnterDetailInfo({super.key, required this.roleId});

  @override
  _EnterDetailInfoState createState() => _EnterDetailInfoState();
}

class _EnterDetailInfoState extends State<EnterDetailInfo> {
  // Controllers
  final TextEditingController carNumberController = TextEditingController();

  // Dropdown data
  List<dynamic> carBrands = [];
  List<dynamic> carModels = [];
  List<dynamic> regions = [];

  // Selected values
  int? selectedCarBrandId;
  int? selectedCarModelId;
  int? selectedFromRegionId;
  int? selectedToRegionId;

  // Loading states
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
      final response = await requestHelper.getWithAuth(
        '/services/zyber/api/ref/get-car-brands',
      );
      setState(() {
        carBrands = response;
        isLoadingBrands = false;
      });
    } catch (e) {
      print('Ошибка загрузки брендов: $e');
    }
  }

  Future<void> fetchCarModels(int brandId) async {
    setState(() {
      isLoadingModels = true;
    });
    try {
      final response = await requestHelper.getWithAuth(
        '/services/zyber/api/ref/get-car-models?brand_id=$brandId',
      );
      setState(() {
        carModels = response;
        isLoadingModels = false;
      });
    } catch (e) {
      print('Ошибка загрузки моделей: $e');
    }
  }

  Future<void> fetchRegions() async {
    try {
      final response = await requestHelper.getWithAuth(
        '/services/zyber/api/ref/get-regions',
      );
      setState(() {
        regions = response;
        isLoadingRegions = false;
      });
    } catch (e) {
      print('Ошибка загрузки регионов: $e');
    }
  }

  Future<void> sendData() async {
    if (selectedFromRegionId == selectedToRegionId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_locations'.tr())),
      );
      return;
    }

    try {
      // Отправка роли
      await requestHelper.putWithAuth(
        '/services/zyber/api/users/update-user-role',
        {'role_id': widget.roleId},
      );

      // Отправка данных
      final response = await requestHelper.postWithAuth(
        '/services/zyber/api/users/add-vehicle',
        {
          'brand_id': selectedCarBrandId,
          'model_id': selectedCarModelId,
          'plate_number': carNumberController.text,
          'from_location': selectedFromRegionId,
          'to_location': selectedToRegionId,
        },
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'succes_send'.tr())),
        );
        print(widget.roleId);
        if (widget.roleId == 2) {
          router.go(Routes.taxiDriverPage);
        } else if (widget.roleId == 3) {
          router.go(Routes.truckDriverPage);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Ошибка отправки.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_conection'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('enter_data'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              isLoadingBrands
                  ? const CircularProgressIndicator()
                  : DropdownButton<int>(
                      isExpanded: true,
                      hint: Text('select_car_brand'.tr()),
                      value: selectedCarBrandId,
                      items: carBrands.map<DropdownMenuItem<int>>((brand) {
                        return DropdownMenuItem<int>(
                          value: brand['id'],
                          child: Text(brand['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCarBrandId = value;
                          selectedCarModelId = null;
                          carModels = [];
                        });
                        fetchCarModels(value!);
                      },
                    ),

              const SizedBox(height: 20),

              isLoadingModels
                  ? const CircularProgressIndicator()
                  : DropdownButton<int>(
                      isExpanded: true,
                      hint: Text('select_car_model'.tr()),
                      value: selectedCarModelId,
                      items: carModels.map<DropdownMenuItem<int>>((model) {
                        return DropdownMenuItem<int>(
                          value: model['id'],
                          child: Text(model['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCarModelId = value;
                        });
                      },
                    ),

              const SizedBox(height: 20),

              TextField(
                controller: carNumberController,
                decoration: InputDecoration(labelText: 'car_number'.tr()),
              ),

              const SizedBox(height: 20),

              isLoadingRegions
                  ? const CircularProgressIndicator()
                  : DropdownButton<int>(
                      isExpanded: true,
                      hint: Text('select_from_location'.tr()),
                      value: selectedFromRegionId,
                      items: regions.map<DropdownMenuItem<int>>((region) {
                        return DropdownMenuItem<int>(
                          value: region['id'],
                          child: Text(region['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFromRegionId = value;
                        });
                      },
                    ),

              const SizedBox(height: 20),

              // To Region Dropdown
              isLoadingRegions
                  ? const CircularProgressIndicator()
                  : DropdownButton<int>(
                      isExpanded: true,
                      hint: Text('select_to_location'.tr()),
                      value: selectedToRegionId,
                      items: regions.map<DropdownMenuItem<int>>((region) {
                        return DropdownMenuItem<int>(
                          value: region['id'],
                          child: Text(region['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedToRegionId = value;
                        });
                      },
                    ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: sendData,
                child: Text('send'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
