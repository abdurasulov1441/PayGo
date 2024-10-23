import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting date
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';
import 'package:url_launcher/url_launcher.dart'; // For phone call functionality
import 'package:firebase_auth/firebase_auth.dart'; // To get current driver

class TruckAcceptedOrdersPage extends StatefulWidget {
  const TruckAcceptedOrdersPage({super.key});

  @override
  State<TruckAcceptedOrdersPage> createState() =>
      _TruckAcceptedOrdersPageState();
}

class _TruckAcceptedOrdersPageState extends State<TruckAcceptedOrdersPage> {
  String? driverEmail;

  @override
  void initState() {
    super.initState();
    _fetchDriverInfo();
  }

  Future<void> _fetchDriverInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        driverEmail = user.email;
      });
    }
  }

  Future<void> _refreshPage() async {
    setState(() {}); // Перезагружаем данные при обновлении страницы
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.taxi,
          title: Text(
            'Qabul qilingan yuk buyurtmalar',
            style: AppStyle.fontStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          )),
      body: driverEmail == null
          ? Center(
              child:
                  CircularProgressIndicator()) // Пока не получен email водителя
          : RefreshIndicator(
              onRefresh: _refreshPage,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('truck_orders')
                    .where('status',
                        isEqualTo: 'qabul qilindi') // Принятые заказы
                    .where('acceptedBy',
                        isEqualTo: driverEmail) // Принятые этим водителем
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Принятые заказы отсутствуют.'));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return Dismissible(
                        key: Key(doc.id),
                        background: _buildDismissBackground(Colors.green,
                            Icons.check, 'Tugatish', Alignment.centerLeft),
                        secondaryBackground: _buildDismissBackground(Colors.red,
                            Icons.undo, 'Qaytarish', Alignment.centerRight),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            _completeOrder(doc.id); // Завершение заказа
                          } else {
                            _returnOrder(doc.id); // Возвращение заказа
                          }
                        },
                        child: InkWell(
                          onTap: () => _callCustomer(
                              doc['phoneNumber']), // Звонок клиенту при нажатии
                          child: _buildOrderCard(doc),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
    );
  }

  // Функция создания фона для Dismissible
  Widget _buildDismissBackground(
      Color color, IconData icon, String label, Alignment alignment) {
    return Container(
      color: color,
      padding: EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 8),
          Text(label,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Функция создания карточки заказа для грузовика
  Widget _buildOrderCard(QueryDocumentSnapshot doc) {
    final orderNumber = doc['orderNumber'];
    final fromLocation = doc['fromLocation'];
    final toLocation = doc['toLocation'];
    final customerName = doc['customerName'];
    final phoneNumber = doc['phoneNumber'];
    final cargoName = doc['cargoName'] ?? 'Unknown'; // Название груза
    final cargoWeight = doc['cargoWeight'] ?? 'Unknown'; // Вес груза
    final orderTime = (doc['orderTime'] as Timestamp).toDate();
    final arrivalTime = orderTime
        .add(Duration(hours: 8)); // Добавляем 8 часов для времени прибытия

    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Номер заказа и время заказа
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Text(
                  _formatDate(orderTime),
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Имя заказчика
            Text(
              customerName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            // Откуда и куда
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qayerdan:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      fromLocation,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDate(orderTime),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward, color: Colors.blue),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Qayerga:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      toLocation,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDate(arrivalTime),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            // Груз и его вес
            Text(
              'Yuk nomi: $cargoName',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              'Yuk vazni: $cargoWeight kg',
              style: TextStyle(fontSize: 16),
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

  // Функция для возврата заказа
  Future<void> _returnOrder(String orderId) async {
    await FirebaseFirestore.instance
        .collection('truck_orders')
        .doc(orderId)
        .update({
      'status': 'kutish jarayonida', // Set status back to pending
      'driverName': null, // Удаление данных о водителе
      'driverPhoneNumber': null,
      'driverTruckModel': null,
      'driverTruckNumber': null,
      'driverEmail': null,
      'driverLastName': null,
      'acceptedBy': null,
    });
    print('Order returned to pending status.');
  }

  // Функция для звонка клиенту
  void _callCustomer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch phone call to $phoneNumber');
    }
  }

  // Функция для завершения заказа
  Future<void> _completeOrder(String orderId) async {
    await FirebaseFirestore.instance
        .collection('truck_orders')
        .doc(orderId)
        .update({
      'status': 'tamomlandi', // Set status to completed
    });
    print('Order marked as completed.');
  }
}
