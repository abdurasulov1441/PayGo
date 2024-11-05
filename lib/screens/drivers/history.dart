import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart'; // For formatting date

class DriverOrderHistoryPage extends StatefulWidget {
  const DriverOrderHistoryPage({super.key});

  @override
  State<DriverOrderHistoryPage> createState() => _DriverOrderHistoryPageState();
}

class _DriverOrderHistoryPageState extends State<DriverOrderHistoryPage> {
  Future<void> _refreshPage() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.taxi,
          title: Text(
            'Buyurtmalar Tarixi',
            style: AppStyle.fontStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          )),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: currentUserEmail == null
            ? Center(child: Text('Foydalanuvchi tizimga kirmagan'))
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('taxi_orders') // Правильная коллекция
                    .where('status',
                        isEqualTo: 'tamomlandi') // Только завершенные заказы
                    .where('driverEmail',
                        isEqualTo: currentUserEmail) // Фильтр по водителю
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('Yakunlangan buyurtmalar mavjud emas.'));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return _buildOrderCard(doc);
                    }).toList(),
                  );
                },
              ),
      ),
    );
  }

  // Функция создания карточки заказа
  Widget _buildOrderCard(QueryDocumentSnapshot doc) {
    final orderNumber = doc['orderNumber'] ?? 'Unknown';
    final customerName = doc['customerName'] ?? 'Unknown';
    final fromLocation = doc['fromLocation'] ?? 'Unknown';
    final toLocation = doc['toLocation'] ?? 'Unknown';
    final orderTime = (doc['orderTime'] as Timestamp).toDate();

    // Рассчитаем время прибытия, добавляя 8 часов
    final arrivalTime = orderTime.add(Duration(hours: 8));

    return Card(
      color: Colors.grey.shade300,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                ),
                Spacer(),
                Text(
                  _formatDate(orderTime),
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              customerName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Qayerdan:', style: TextStyle(color: Colors.grey)),
                      Text(fromLocation,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_formatDate(orderTime),
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.blue),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Qayerga:', style: TextStyle(color: Colors.grey)),
                      Text(toLocation,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_formatDate(arrivalTime),
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Для такси выводим количество людей
            Text(
              'Odamlar soni: ${doc['peopleCount'] ?? 'Unknown'}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Функция для форматирования времени заказа
  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }
}
