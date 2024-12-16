import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TruckAcceptedOrdersPage extends StatefulWidget {
  const TruckAcceptedOrdersPage({super.key});

  @override
  State<TruckAcceptedOrdersPage> createState() =>
      _TruckAcceptedOrdersPageState();
}

class _TruckAcceptedOrdersPageState extends State<TruckAcceptedOrdersPage> {
  String? driverId;

  @override
  void initState() {
    super.initState();
    _fetchDriverId();
  }

  Future<void> _fetchDriverId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('truckdrivers')
          .where('email', isEqualTo: user.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          driverId = snapshot.docs.first.id;
        });
      }
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
            'Qabul qilingan yuk buyurtmalar',
            style: AppStyle.fontStyle.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          )),
      body: driverId == null
          ? Center(
              child: LottieBuilder.asset('assets/lottie/loading.json'),
            )
          : RefreshIndicator(
              onRefresh: _refreshPage,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('truck_orders')
                    .where('status', isEqualTo: 'qabul qilindi')
                    .where('accepted_by', isEqualTo: driverId)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('Qabul qilingan buyurtmalar mavjud emas.'));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('user')
                            .doc(doc['user_id'])
                            .get(),
                        builder: (context, passengerSnapshot) {
                          if (!passengerSnapshot.hasData) {
                            return SizedBox();
                          }

                          final passengerData = passengerSnapshot.data;
                          final passengerName =
                              passengerData?['name'] ?? 'Unknown';
                          final passengerPhone =
                              passengerData?['phone_number'] ?? 'Unknown';

                          return Dismissible(
                            key: Key(doc.id),
                            background: _buildDismissBackground(Colors.green,
                                Icons.check, 'Tugatish', Alignment.centerLeft),
                            secondaryBackground: _buildDismissBackground(
                                Colors.red,
                                Icons.undo,
                                'Qaytarish',
                                Alignment.centerRight),
                            onDismissed: (direction) {
                              if (direction == DismissDirection.startToEnd) {
                                _completeOrder(doc.id);
                              } else {
                                _returnOrder(doc.id);
                              }
                            },
                            child: InkWell(
                              onTap: () => _callCustomer(passengerPhone),
                              child: _buildOrderCard(
                                  doc, passengerName, passengerPhone),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
    );
  }

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

  Widget _buildOrderCard(
      QueryDocumentSnapshot doc, String passengerName, String passengerPhone) {
    final orderNumber = doc.id;
    final fromLocation = doc['from'];
    final toLocation = doc['to'];
    final cargoName = doc['cargo_name'] ?? 'Unknown';
    final cargoWeight = doc['cargo_weight'] ?? 'Unknown';
    final orderTime = (doc['accept_time'] as Timestamp).toDate();

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
            Text(
              'Yo\'lovchi: $passengerName',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.phone, color: AppColors.taxi),
                SizedBox(width: 8),
                Text(
                  'Telefon: $passengerPhone',
                  style: TextStyle(fontSize: 16, color: AppColors.taxi),
                ),
              ],
            ),
            SizedBox(height: 10),
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
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Yuk nomi: $cargoName',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              'Yuk vazni: $cargoWeight kg',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showBanPassengerDialog(doc['user_id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.taxi,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Shikoyat",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  Future<void> _returnOrder(String orderId) async {
    await FirebaseFirestore.instance
        .collection('truck_orders')
        .doc(orderId)
        .update({
      'status': 'kutish jarayonida',
      'accepted_by': null,
    });
  }

  void _callCustomer(String phoneNumber) async {
    String sanitizedPhoneNumber =
        phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    final intent = AndroidIntent(
      action: 'android.intent.action.CALL',
      data: 'tel:$sanitizedPhoneNumber',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );

    try {
      await intent.launch();
    } catch (e) {
      _showSnackBar(
          'Qo‘ng‘iroq amalga oshmadi. Telefon sozlamalarini tekshiring.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _completeOrder(String orderId) async {
    await FirebaseFirestore.instance
        .collection('truck_orders')
        .doc(orderId)
        .update({
      'status': 'tamomlandi',
    });
  }

  Future<void> _showBanPassengerDialog(String passengerId) async {
    final driverId = this.driverId;
    if (driverId == null) {
      _showSnackBar("Xatolik: Haydovchi tizimga kirmagan.");
      return;
    }

    final banDocRef =
        FirebaseFirestore.instance.collection('banlistuser').doc(passengerId);

    QuerySnapshot existingComplaintSnapshot = await banDocRef
        .collection('complaints')
        .where('driverId', isEqualTo: driverId)
        .get();

    if (existingComplaintSnapshot.docs.isNotEmpty) {
      _showSnackBar('Siz ushbu yo‘lovchiga allaqachon shikoyat qildingiz.');
      return;
    }

    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.feedback, color: Colors.red),
              SizedBox(width: 8),
              Text("Shikoyat qilish"),
            ],
          ),
          content: Text("Haqiqatan ham ushbu yo‘lovchini ban qilmoqchimisiz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Yo'q", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.taxi,
              ),
              child: Text(
                "Ha",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (!confirm) return;

    await banDocRef.collection('complaints').add({
      'driverId': driverId,
      'timestamp': DateTime.now(),
    });

    _showSnackBar('Yo‘lovchi muvaffaqiyatli ban qilindi.');
  }
}
