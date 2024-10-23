import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TruckOrderHistoryPage extends StatefulWidget {
  const TruckOrderHistoryPage({super.key});

  @override
  _TruckOrderHistoryPageState createState() => _TruckOrderHistoryPageState();
}

class _TruckOrderHistoryPageState extends State<TruckOrderHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.taxi,
          title: Text(
            'Yuk buyurtmalari tarixi',
            style: AppStyle.fontStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('truck_orders') // Обращаемся к коллекции truck_orders
              .where('userEmail',
                  isEqualTo:
                      userEmail) // Фильтруем заказы по email пользователя
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Buyurtmalar mavjud emas'));
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: snapshot.data!.docs.map((doc) {
                return _buildTruckOrderCard(
                    doc); // Строим карточки только для truck_orders
              }).toList(),
            );
          },
        ));
  }

  Widget _buildTruckOrderCard(DocumentSnapshot doc) {
    String orderNumber =
        (doc.data() as Map<String, dynamic>).containsKey('orderNumber')
            ? doc['orderNumber'].toString()
            : 'No Number';
    String customerName = doc['customerName'] ?? 'Ism mavjud emas';
    String fromLocation = doc['fromLocation'] ?? 'Unknown';
    String toLocation = doc['toLocation'] ?? 'Unknown';
    double cargoWeight = doc['cargoWeight'] ?? 0.0;
    String cargoName = doc['cargoName'] ?? 'Yuk nomi mavjud emas';
    String orderStatus = doc['status'] ?? 'Status mavjud emas'; // Статус заказа
    DateTime orderTime = (doc['orderTime'] as Timestamp).toDate();
    DateTime arrivalTime = orderTime.add(Duration(hours: 8));

    // Определение цвета для статуса в зависимости от его значения
    Color getStatusColor(String status) {
      if (status == 'qabul qilindi') {
        return Colors.orange; // Оранжевый цвет для статуса "qabul qilindi"
      } else if (status == 'tamomlandi') {
        return Colors.green; // Зеленый для завершенных заказов
      } else {
        return Colors.red; // Красный для остальных статусов
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildOrderNumberTag(orderNumber),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(orderTime),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4), // Отступ между датой и статусом
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: getStatusColor(
                            orderStatus), // Устанавливаем цвет в зависимости от статуса
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        orderStatus,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              customerName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildLocationRow(fromLocation, toLocation, orderTime, arrivalTime),
            SizedBox(height: 10),
            Text(
              'Yuk nomi: $cargoName',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 8),
            Text(
              'Yuk vazni: ${cargoWeight.toStringAsFixed(2)} kg',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNumberTag(String orderNumber) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Buyurtma №$orderNumber',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLocationRow(String fromLocation, String toLocation,
      DateTime orderTime, DateTime arrivalTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Qayerdan:',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(fromLocation,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_formatDate(orderTime),
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        Icon(Icons.arrow_forward, color: Colors.blue),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Qayerga:',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(toLocation,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_formatDate(arrivalTime),
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }
}
