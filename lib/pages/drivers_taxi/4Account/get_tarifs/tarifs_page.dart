import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taksi/services/request_helper.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TariffsPage extends StatefulWidget {
  const TariffsPage({super.key});

  @override
  _TariffsPageState createState() => _TariffsPageState();
}

class _TariffsPageState extends State<TariffsPage> {
  List<Map<String, dynamic>> tariffsFromSever = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTariffs();
  }

  Future<void> _fetchTariffs() async {
    try {
      final response = await requestHelper
          .getWithAuth('/services/zyber/api/ref/get-tariffs', log: true);

      if (response != null && response is List) {
        setState(() {
          tariffsFromSever = List<Map<String, dynamic>>.from(response);
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

  final List<Map<String, dynamic>> tariffs = [
    {
      "id": 1,
      "name": "1 Oy",
      "price": "30 000",
      "discount": 0,
      "monthly": "30 000 so'm/oy"
    },
    {
      "id": 2,
      "name": "3 Oy",
      "price": "85 000",
      "discount": 5,
      "monthly": "28 333 so'm/oy"
    },
    {
      "id": 3,
      "name": "6 Oy",
      "price": "160 000",
      "discount": 10,
      "monthly": "26 666 so'm/oy"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.backgroundColor,
          ),
        ),
        title: Text(
          'Tariflar',
          style: AppStyle.fontStyle.copyWith(
            color: AppColors.backgroundColor,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.grade1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tariffs.length,
        itemBuilder: (context, index) {
          final tariff = tariffs[index];
          return _buildTariffCard(tariff, index);
        },
      ),
    );
  }

  Widget _buildTariffCard(Map<String, dynamic> tariff, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: index == 2 ? AppColors.grade1 : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${tariff['name']}',
            style: AppStyle.fontStyle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tariff['discount'] > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Save ${tariff['discount']}%',
                        style: AppStyle.fontStyle.copyWith(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '${tariff['price']} so\'m',
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grade1,
                    ),
                  ),
                ],
              ),
              Text(
                '${tariff['monthly']}',
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (index == 2)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.grade1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Hot',
                  style: AppStyle.fontStyle.copyWith(
                    color: AppColors.backgroundColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _selectTariff(tariff['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grade1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                'Obuna bo\'lish',
                style: AppStyle.fontStyle.copyWith(
                  color: AppColors.backgroundColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTariff(int tariffId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Siz $tariffId-idli tarifni tanladingiz!'),
        backgroundColor: AppColors.grade1,
      ),
    );
  }
}
