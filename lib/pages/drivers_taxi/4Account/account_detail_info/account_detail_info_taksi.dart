import 'package:flutter/material.dart';
import 'package:taksi/services/request_helper.dart';

class AccountDetailInfoTaksi extends StatefulWidget {
  const AccountDetailInfoTaksi({super.key});

  @override
  State<AccountDetailInfoTaksi> createState() => _AccountDetailInfoTaksiState();
}

class _AccountDetailInfoTaksiState extends State<AccountDetailInfoTaksi> {

  Future<void> _fetchDetailInfo() async {
    try {
      final response = await requestHelper
          .getWithAuth('/services/zyber/api/ref/get-tariffs', log: true);

      if (response != null && response is List) {
        setState(() {
         
        });
      } else {
       
      }
    } catch (e) {
      
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tarif rejasi : 1 oylik',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tarif tugash muddati : 2025.08.19',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
