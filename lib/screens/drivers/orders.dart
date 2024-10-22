import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class BuyurtmalarPage extends StatefulWidget {
  const BuyurtmalarPage({super.key});

  @override
  _BuyurtmalarPageState createState() => _BuyurtmalarPageState();
}

class _BuyurtmalarPageState extends State<BuyurtmalarPage> {
  String? driverRegion;
  String? driverVehicleType;
  bool isLoading = true;
  Future<void> _refreshPage() async {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  Future<void> _fetchDriverData() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email;
      final snapshot = await FirebaseFirestore.instance
          .collection('driver')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final driverData = snapshot.docs.first.data();
        setState(() {
          driverRegion = driverData['to']; // Destination region of driver
          driverVehicleType = driverData['vehicleType']; // Vehicle type
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching driver data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.taxi,
        title: Text(
          'Buyurtmalar',
          style: AppStyle.fontStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : driverRegion == null || driverVehicleType == null
                ? Center(child: Text('No driver data found'))
                : _buildOrderStream(),
      ),
    );
  }

  Widget _buildOrderStream() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'kutish jarayonida')
          .where('orderType',
              isEqualTo:
                  driverVehicleType == 'Yengil avtomobil' ? 'taksi' : 'truck')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final filteredOrders = snapshot.data!.docs.where((doc) {
          final fromLocation = doc['fromLocation'];
          final toLocation = doc['toLocation'];
          return fromLocation == driverRegion || toLocation == driverRegion;
        }).toList();

        if (filteredOrders.isEmpty) {
          return Center(child: Text('Buyurtmalar mavjud emas'));
        }

        return ListView(
          children: filteredOrders.map((doc) {
            return _buildOrderCard(doc);
          }).toList(),
        );
      },
    );
  }

  Widget _buildOrderCard(QueryDocumentSnapshot doc) {
    final orderNumber = doc['orderNumber'] ?? 'Unknown';

    // Check if 'customerName' or 'cargoName' exists and provide default value
    final customerName =
        (doc.data() as Map<String, dynamic>).containsKey('customerName')
            ? doc['customerName']
            : 'Unknown';
    final fromLocation = doc['fromLocation'] ?? 'Unknown';
    final toLocation = doc['toLocation'] ?? 'Unknown';
    final orderTime = (doc['orderTime'] as Timestamp).toDate();
    final arrivalTime = orderTime.add(Duration(hours: 8));
    final orderType = doc['orderType'] ?? 'Unknown';

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        color: Colors.green,
        child: Icon(Icons.check, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) {
        _acceptOrder(doc.id);
      },
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
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
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              customerName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qayerdan:',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        fromLocation,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(orderTime),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.blue),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Qayerga:',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        toLocation,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatDate(arrivalTime),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (orderType == 'taksi') ...[
              Text('Odamlar soni: ${doc['peopleCount'] ?? 'Unknown'}'),
            ] else if (orderType == 'truck') ...[
              Text('Yuk nomi: ${doc['cargoName'] ?? 'Unknown'}'),
              Text('Yuk vazni: ${doc['cargoWeight'] ?? 'Unknown'} kg'),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  Future<void> _acceptOrder(String orderId) async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email;
      final snapshot = await FirebaseFirestore.instance
          .collection('driver')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final driverData = snapshot.docs.first.data();

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({
          'status': 'qabul qilindi',
          'driverName': driverData['name'],
          'driverPhoneNumber': driverData['phoneNumber'],
          'driverCarModel': driverData['carModel'],
          'driverCarNumber': driverData['carNumber'],
          'driverEmail': driverData['email'],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Buyurtma qabul qilindi!')),
        );
      }
    } catch (e) {
      print("Error accepting order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik yuz berdi!')),
      );
    }
  }
}
