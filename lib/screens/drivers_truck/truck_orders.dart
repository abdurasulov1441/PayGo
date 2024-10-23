import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TruckOrdersPage extends StatefulWidget {
  const TruckOrdersPage({super.key});

  @override
  _TruckOrdersPageState createState() => _TruckOrdersPageState();
}

class _TruckOrdersPageState extends State<TruckOrdersPage> {
  String? selectedFromRegion;
  String? selectedToRegion;
  String? driverRegion;
  String? subscriptionPlan;
  List<String> regions = [];
  bool isLoading = true;
  bool isFilterReversed = false;

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
    _fetchRegions();
  }

  Future<void> _acceptOrder(String orderId) async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email;
      final snapshot = await FirebaseFirestore.instance
          .collection('truckdrivers')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final driverData = snapshot.docs.first.data();
        print('Данные для обновления заказа: $driverData'); // Отладка

        await FirebaseFirestore.instance
            .collection('truck_orders')
            .doc(orderId)
            .update({
          'status': 'qabul qilindi',
          'acceptedBy': driverData['email'],
          'driverEmail': driverData['email'],
          'driverName': driverData['name'],
          'driverPhoneNumber': driverData['phoneNumber'],
          'driverTruckModel': driverData['truckModel'],
          'driverTruckNumber': driverData['truckNumber'],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Buyurtma qabul qilindi!')),
        );
      } else {
        print('Водитель не найден для обновления заказа');
      }
    } catch (e) {
      print("Ошибка принятия заказа: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik yuz berdi!')),
      );
    }
  }

  Future<void> _fetchDriverData() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email;
      final snapshot = await FirebaseFirestore.instance
          .collection('truckdrivers')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final driverData = snapshot.docs.first.data();
        setState(() {
          driverRegion = driverData['from'] ?? ''; // Регион водителя
          selectedToRegion = driverData['to'] ?? ''; // Регион назначения
          subscriptionPlan = driverData['subscription_plan'];
        });
      }
    } catch (e) {
      print("Error fetching driver data: $e");
    }
  }

  Future<void> _fetchRegions() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('regions').get();
      setState(() {
        regions = snapshot.docs.map((doc) => doc['region'].toString()).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching regions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Stream<QuerySnapshot> _fetchOrders() {
    final fromLocation = isFilterReversed ? 'Toshkent sh' : driverRegion!;
    final toLocation = isFilterReversed ? driverRegion! : 'Toshkent sh';

    // Fetch orders where fromLocation and toLocation match the required regions
    final fromQuery = FirebaseFirestore.instance
        .collection('truck_orders')
        .where('fromLocation', isEqualTo: fromLocation)
        .where('toLocation', isEqualTo: toLocation)
        .where('status', isEqualTo: 'kutish jarayonida')
        .snapshots();
    print("Fetching orders from: $fromLocation to: $toLocation");

    return fromQuery;
  }

  Widget _buildOrderStream() {
    return StreamBuilder(
      stream: _fetchOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Buyurtmalar mavjud emas'));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return _buildOrderCard(doc);
          }).toList(),
        );
      },
    );
  }

  Widget _buildOrderCard(QueryDocumentSnapshot doc) {
    final orderNumber = doc['orderNumber'] ?? 'Unknown';
    final customerName = doc['customerName'] ?? 'Unknown'; // Имя клиента
    final fromLocation = doc['fromLocation'] ?? 'Unknown';
    final toLocation = doc['toLocation'] ?? 'Unknown';
    final cargoWeight = doc['cargoWeight'] ?? 0.0; // Вес груза
    final cargoName = doc['cargoName'] ?? 'Неизвестно'; // Название груза
    final orderTime = (doc['orderTime'] as Timestamp).toDate();
    final arrivalTime = orderTime.add(Duration(hours: 8));

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.check, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) {
        _acceptOrder(doc.id); // Принятие заказа при свайпе
      },
      child: Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
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
                          color: Colors.white, fontWeight: FontWeight.bold),
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
              SizedBox(height: 10),
              Text(
                customerName, // Имя клиента
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Qayerdan:',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(fromLocation,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
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
                        Text('Qayerga:',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(toLocation,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(_formatDate(arrivalTime),
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text('Yuk nomi: $cargoName'), // Название груза
              SizedBox(height: 5),
              Text('Yuk vazni: $cargoWeight kg'), // Вес груза
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Buyurtmalar',
          style: AppStyle.fontStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (subscriptionPlan != 'Vaqtinchalik') ...[
                    SizedBox(height: 20),
                  ],
                  Expanded(child: _buildOrderStream()),
                ],
              ),
            ),
    );
  }
}
