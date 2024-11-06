import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TruckOrderHistoryPage extends StatefulWidget {
  const TruckOrderHistoryPage({super.key});

  @override
  State<TruckOrderHistoryPage> createState() => _TruckOrderHistoryPageState();
}

class _TruckOrderHistoryPageState extends State<TruckOrderHistoryPage> {
  String? driverId;

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  Future<void> _fetchDriverData() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email;
      if (userEmail != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('truckdrivers')
            .where('email', isEqualTo: userEmail)
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            driverId = snapshot.docs.first.id; // Получаем ID водителя
          });
        } else {
          print('Driver not found');
        }
      }
    } catch (e) {
      print("Error fetching driver data: $e");
    }
  }

  Future<void> _refreshPage() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.taxi,
        title: Text(
          'Yuk Buyurtmalar Tarixi',
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: driverId == null
            ? Center(child: CircularProgressIndicator())
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('truck_orders')
                    .where('status',
                        isEqualTo:
                            'tamomlandi') // Фильтрация по статусу завершённого заказа
                    .where('accepted_by',
                        isEqualTo: driverId) // Фильтрация по ID водителя
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
    final data = doc.data() as Map<String, dynamic>;

    final orderNumber = doc.id; // Используем ID документа как номер заказа
    final fromLocation = data['from'] ?? 'Unknown';
    final toLocation = data['to'] ?? 'Unknown';
    final cargoName = data['cargo_name'] ?? 'Unknown';
    final cargoWeight = data['cargo_weight'] ?? 0.0;
    final orderTime = (data['chosen_time'] as Timestamp).toDate();
    final arrivalTime = (data['accept_time'] as Timestamp).toDate();

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
            Text(
              'Yuk nomi: $cargoName',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Yuk vazni: ${cargoWeight.toStringAsFixed(2)} kg',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }
}
