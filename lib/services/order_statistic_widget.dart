// order_statistics_widget.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taksi/style/app_style.dart';

class OrderStatisticsWidget extends StatelessWidget {
  const OrderStatisticsWidget({Key? key}) : super(key: key);

  Stream<int> _getOrderCountStream(String status) {
    return FirebaseFirestore.instance
        .collection('truck_orders')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Stream<int> _totalOrdersStream() {
    return FirebaseFirestore.instance
        .collection('truck_orders')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 2.5,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _buildStatisticItem('Umumiy', Colors.blue, _totalOrdersStream()),
        _buildStatisticItem('Qabul qilindi', Colors.purple,
            _getOrderCountStream('qabul qilindi')),
        _buildStatisticItem('Jarayonda', Colors.orange,
            _getOrderCountStream('kutish jarayonida')),
        _buildStatisticItem(
            'Tamomlandi', Colors.green, _getOrderCountStream('tamomlandi')),
      ],
    );
  }

  Widget _buildStatisticItem(
      String title, Color color, Stream<int> countStream) {
    return StreamBuilder<int>(
      stream: countStream,
      builder: (context, snapshot) {
        int count = snapshot.data ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
