import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TruckOrderHistoryPage extends StatefulWidget {
  const TruckOrderHistoryPage({super.key});

  @override
  _TruckOrderHistoryPageState createState() => _TruckOrderHistoryPageState();
}

class _TruckOrderHistoryPageState extends State<TruckOrderHistoryPage> {
  Map<String, double> orderRatings = {};
  Map<String, String> ratingDocIds = {};
  Map<String, bool> expandedStates = {}; // Store expanded state for each order

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('driverTruckRatings')
          .where('ratedBy', isEqualTo: currentUserEmail)
          .get();

      setState(() {
        for (var doc in ratingsSnapshot.docs) {
          orderRatings[doc['orderId']] = doc['rating'].toDouble();
          ratingDocIds[doc['orderId']] = doc.id;
        }
      });
    }
  }

  void _callDriver(String phoneNumber) async {
    // Sanitize the phone number by removing any non-numeric or non-plus characters
    String sanitizedPhoneNumber =
        phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    // Create the intent to make a call
    final intent = AndroidIntent(
      action: 'android.intent.action.CALL',
      data: 'tel:$sanitizedPhoneNumber',
      flags: <int>[
        Flag.FLAG_ACTIVITY_NEW_TASK
      ], // Ensure a new task is created for the call
    );

    try {
      // Launch the phone call intent
      await intent.launch();
    } catch (e) {
      // Handle any errors that occur when launching the intent
      print('Could not launch phone call to $sanitizedPhoneNumber: $e');
      _showSnackBar('Call failed. Please check phone settings.');
    }
  }

  void _showSnackBar(String message) {
    // Display a snackbar with the provided message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
              .collection('truck_orders')
              .where('userEmail', isEqualTo: userEmail)
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
                return _buildTruckOrderCard(doc);
              }).toList(),
            );
          },
        ));
  }

  Widget _buildTruckOrderCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String orderNumber = data.containsKey('orderNumber')
        ? data['orderNumber'].toString()
        : 'No Number';
    String customerName = data.containsKey('customerName')
        ? data['customerName'] ?? 'Ism mavjud emas'
        : 'Ism mavjud emas';
    String fromLocation = data.containsKey('fromLocation')
        ? data['fromLocation'] ?? 'Unknown'
        : 'Unknown';
    String toLocation = data.containsKey('toLocation')
        ? data['toLocation'] ?? 'Unknown'
        : 'Unknown';
    double cargoWeight = data.containsKey('cargoWeight')
        ? (data['cargoWeight'] as num).toDouble()
        : 0.0;
    String cargoName = data.containsKey('cargoName')
        ? data['cargoName'] ?? 'Yuk nomi mavjud emas'
        : 'Yuk nomi mavjud emas';
    String orderStatus = data.containsKey('status')
        ? data['status'] ?? 'Status mavjud emas'
        : 'Status mavjud emas';
    DateTime orderTime = (data['orderTime'] as Timestamp).toDate();
    DateTime arrivalTime = orderTime.add(Duration(hours: 8));
    String orderId = doc.id;

    // Driver Information
    String driverName = data.containsKey('driverName')
        ? data['driverName'] ?? 'Ism mavjud emas'
        : 'Ism mavjud emas';
    String driverPhoneNumber = data.containsKey('driverPhoneNumber')
        ? data['driverPhoneNumber'] ?? 'Telefon raqami mavjud emas'
        : 'Telefon raqami mavjud emas';
    String driverTruckModel = data.containsKey('driverTruckModel')
        ? data['driverTruckModel'] ?? 'Mashina mavjud emas'
        : 'Mashina mavjud emas';
    String driverTruckNumber = data.containsKey('driverTruckNumber')
        ? data['driverTruckNumber'] ?? 'Avtomobil raqami mavjud emas'
        : 'Avtomobil raqami mavjud emas';

    bool isExpanded = expandedStates[orderId] ?? false;

    // Определяем цвет статуса
    Color getStatusColor(String status) {
      if (status == 'qabul qilindi') {
        return Colors.orange;
      } else if (status == 'tamomlandi') {
        return Colors.green;
      } else {
        return Colors.red;
      }
    }

    return GestureDetector(
      onTap: () {
        // Если заказ еще не принят, карточка не расширяется
        if (orderStatus == 'qabul qilindi') {
          setState(() {
            expandedStates[orderId] = !isExpanded; // Переключаем состояние
          });
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1),
          ],
        ),
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
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: getStatusColor(orderStatus),
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
            SizedBox(height: 10),
            if (orderStatus == 'tamomlandi') _buildRatingBar(orderId),

            // Данные водителя отображаются только если заказ принят и карточка расширена
            if (orderStatus == 'qabul qilindi' && isExpanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Haydovchi: $driverName',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.green),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _callDriver(
                            driverPhoneNumber), // Call the driver when tapped
                        child: Text(
                          'Telefon raqami: $driverPhoneNumber',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text('Mashina modeli: $driverTruckModel',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  SizedBox(height: 4),
                  Text('Mashina raqami: $driverTruckNumber',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                ],
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

  Widget _buildRatingBar(String orderId) {
    double initialRating = orderRatings[orderId] ?? 0.0;

    return RatingBar.builder(
      initialRating: initialRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
      onRatingUpdate: (rating) {
        setState(() {
          orderRatings[orderId] = rating;
        });
        _saveOrUpdateRating(orderId, rating);
      },
    );
  }

  Future<void> _saveOrUpdateRating(String orderId, double rating) async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      if (ratingDocIds.containsKey(orderId)) {
        await FirebaseFirestore.instance
            .collection('driverTruckRatings')
            .doc(ratingDocIds[orderId])
            .update({
          'rating': rating,
        });
      } else {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('driverTruckRatings')
            .add({
          'orderId': orderId,
          'rating': rating,
          'ratedBy': currentUserEmail,
        });

        setState(() {
          ratingDocIds[orderId] = docRef.id;
        });
      }
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }
}
