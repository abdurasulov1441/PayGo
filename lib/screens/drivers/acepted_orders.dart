import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting date
import 'package:permission_handler/permission_handler.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';
import 'package:url_launcher/url_launcher.dart'; // For phone call functionality
import 'package:firebase_auth/firebase_auth.dart'; // To get current driver

class AcceptedOrdersPage extends StatefulWidget {
  const AcceptedOrdersPage({super.key});

  @override
  State<AcceptedOrdersPage> createState() => _AcceptedOrdersPageState();
}

class _AcceptedOrdersPageState extends State<AcceptedOrdersPage> {
  String? driverEmail;

  @override
  void initState() {
    super.initState();
    _fetchDriverInfo();
  }

  Future<void> _callPassenger(String phoneNumber) async {
    // Sanitize the phone number by removing spaces, parentheses, and other non-numeric characters
    String sanitizedPhoneNumber =
        phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    // Check for phone call permission
    PermissionStatus permissionStatus = await Permission.phone.status;

    if (permissionStatus.isGranted) {
      final intent = AndroidIntent(
        action: 'android.intent.action.CALL',
        data: Uri.encodeFull('tel:$sanitizedPhoneNumber'),
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );

      try {
        await intent.launch();
      } catch (e) {
        _showSnackBar(
            'Qo\'ng\'iroq amalga oshirilmadi. Iltimos, telefon sozlamalarini tekshiring.');
      }
    } else {
      // Request permission if not granted
      PermissionStatus status = await Permission.phone.request();
      if (status.isGranted) {
        _callPassenger(phoneNumber); // Retry after permission is granted
      } else {
        _showSnackBar('Qo\'ng\'iroq qilish uchun telefon ruxsati kerak.');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
    setState(() {}); // Refresh page data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.taxi,
          title: Text(
            'Qabul qilingan buyurtmalar',
            style: AppStyle.fontStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          )),
      body: driverEmail == null
          ? Center(
              child:
                  CircularProgressIndicator()) // While driver email is loading
          : RefreshIndicator(
              onRefresh: _refreshPage,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('taxi_orders')
                    .where('status',
                        isEqualTo: 'qabul qilindi') // Accepted orders
                    .where('acceptedBy',
                        isEqualTo: driverEmail) // Accepted by this driver
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
                            _completeOrder(doc.id); // Complete the order
                          } else {
                            _returnOrder(doc.id); // Return the order
                          }
                        },
                        child: InkWell(
                          onTap: () => _callPassenger, // Call passenger on tap
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

  // Function to build the Dismissible background
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

  // Function to build the order card with phone number displayed
  Widget _buildOrderCard(QueryDocumentSnapshot doc) {
    final orderNumber = doc['orderNumber'];
    final fromLocation = doc['fromLocation'];
    final toLocation = doc['toLocation'];
    final customerName = doc['customerName'];
    final phoneNumber = doc['phoneNumber'];
    final peopleCount = doc['peopleCount'] ?? 'Unknown'; // Number of people
    final orderTime = (doc['orderTime'] as Timestamp).toDate();
    final arrivalTime = orderTime
        .add(Duration(hours: 8)); // Add 8 hours to order time for arrival

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
            // Order number and time
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
            // Customer name
            Text(
              customerName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            // Locations
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
            // Number of people (for taxi orders)
            Text(
              'Odamlar soni: $peopleCount',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            // Display phone number
            Row(
              children: [
                Icon(Icons.phone, color: AppColors.taxi),
                SizedBox(width: 8),
                Text(
                  'Telefon: $phoneNumber',
                  style: TextStyle(fontSize: 16, color: AppColors.taxi),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to format date
  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  // Function to return an order to pending status
  Future<void> _returnOrder(String orderId) async {
    await FirebaseFirestore.instance
        .collection('taxi_orders')
        .doc(orderId)
        .update({
      'status': 'kutish jarayonida',
      'driverName': null,
      'driverPhoneNumber': null,
      'driverCarModel': null,
      'driverCarNumber': null,
      'driverEmail': null,
      'driverLastName': null,
      'acceptedBy': null,
    });
    print('Order returned to pending status.');
  }

  // Function to call the passenger

  // Function to complete an order
  Future<void> _completeOrder(String orderId) async {
    await FirebaseFirestore.instance
        .collection('taxi_orders')
        .doc(orderId)
        .update({
      'status': 'tamomlandi',
    });
    print('Order marked as completed.');
  }
}
