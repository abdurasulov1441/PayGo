import 'package:flutter/material.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TariffsPage extends StatefulWidget {
  const TariffsPage({super.key});

  @override
  _TariffsPageState createState() => _TariffsPageState();
}

class _TariffsPageState extends State<TariffsPage> {
  List<Map<String, dynamic>> tariffs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTariffs();
  }

  Future<void> _fetchTariffs() async {
    try {
      final response = await requestHelper.getWithAuth(
        '/services/zyber/api/ref/get-tariffs',
      );

      if (response != null && response is List) {
        setState(() {
          tariffs = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tariflarni yuklashda xatolik!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarmoq xatoligi!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tariflar',
          style: AppStyle.fontStyle.copyWith(
            color: AppColors.backgroundColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.grade1,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : tariffs.isEmpty
              ? const Center(
                  child: Text(
                    'Tariflar mavjud emas',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tariffs.length,
                  itemBuilder: (context, index) {
                    final tariff = tariffs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(
                          tariff['name'],
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${tariff['price']} UZS',
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _selectTariff(tariff['id']);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.grade1,
                          ),
                          child: Text(
                            'Obuna bo\'lish',
                            style: AppStyle.fontStyle
                                .copyWith(color: AppColors.backgroundColor),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _selectTariff(int tariffId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Siz ${tariffId}-idli tarifni tanladingiz!'),
        backgroundColor: AppColors.grade1,
      ),
    );
  }
}
