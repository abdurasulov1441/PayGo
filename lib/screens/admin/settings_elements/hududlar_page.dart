import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class HududlarPage extends StatelessWidget {
  const HududlarPage({super.key});

  Future<List<String>> _getRegions() async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
        .collection('data')
        .doc('regions')
        .get();

    if (doc.exists && doc.data() != null) {
      List<dynamic> regions = doc.data()!['regions'];
      return List<String>.from(regions);
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hududlar',
          style: AppStyle.fontStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: FutureBuilder<List<String>>(
        future: _getRegions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Xatolik yuz berdi!',
                style: AppStyle.fontStyle,
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Hududlar mavjud emas',
                style: AppStyle.fontStyle,
              ),
            );
          }

          List<String> regions = snapshot.data!;

          return ListView.builder(
            itemCount: regions.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    regions[index],
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
