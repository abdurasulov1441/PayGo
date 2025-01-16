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
        const SnackBar(
            content:
                Text('Выберите разные области для отправления и прибытия.')),
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
          SnackBar(content: Text(response['message'] ?? 'Успешно отправлено.')),
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
      print('Ошибка при отправке данных: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка сети. Попробуйте снова.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Введите данные')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Car Brand Dropdown
              isLoadingBrands
                  ? const CircularProgressIndicator()
                  : DropdownButton<int>(
                      isExpanded: true,
                      hint: const Text('Выберите бренд машины'),
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

              // Car Model Dropdown
              isLoadingModels
                  ? const CircularProgressIndicator()
                  : DropdownButton<int>(
                      isExpanded: true,
                      hint: const Text('Выберите модель машины'),
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

              // Car Number Input
              TextField(
                controller: carNumberController,
                decoration: const InputDecoration(labelText: 'Номер машины'),
              ),

              const SizedBox(height: 20),

              // From Region Dropdown
              isLoadingRegions
                  ? const CircularProgressIndicator()
                  : DropdownButton<int>(
                      isExpanded: true,
                      hint: const Text('Выберите область отправления'),
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
                      hint: const Text('Выберите область прибытия'),
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

              // Submit Button
              ElevatedButton(
                onPressed: sendData,
                child: const Text('Отправить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
