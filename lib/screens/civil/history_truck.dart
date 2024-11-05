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
      _showSnackBar('Call failed. Please check phone settings.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: Colors.white,
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
      ),
    );
  }

  Future<void> checkAndHandleBan(String driverUserId) async {
    final complaintSnapshot = await FirebaseFirestore.instance
        .collection('complaints')
        .where('driverUserId', isEqualTo: driverUserId)
        .get();

    final uniqueUserEmails =
        complaintSnapshot.docs.map((doc) => doc['userEmail']).toSet().toList();

    if (uniqueUserEmails.length >= 3) {
      // If 3 or more unique complaints, set status to inactive
      await FirebaseFirestore.instance
          .collection('truckdrivers')
          .doc(driverUserId)
          .update({'status': 'inactive'});
    }
  }

  Future<void> showComplaintDialog(
      BuildContext context,
      String orderId,
      String driverUserId,
      String userEmail,
      String driverName,
      String driverPhoneNumber) async {
    TextEditingController complaintController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Please describe your issue"),
          content: TextField(
            controller: complaintController,
            maxLines: 3,
            decoration: InputDecoration(hintText: "Describe the issue here"),
          ),
          actions: [
            TextButton(
              child: Text("Submit"),
              onPressed: () async {
                final complaintText = complaintController.text;
                if (complaintText.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('complaints')
                      .add({
                    'orderId': orderId,
                    'driverUserId': driverUserId,
                    'userEmail': userEmail,
                    'driverName': driverName,
                    'driverPhoneNumber': driverPhoneNumber,
                    'complaint': complaintText,
                    'timestamp': DateTime.now(),
                  });

                  // Optional: You can call the ban check here if you want immediate processing
                  await checkAndHandleBan(driverUserId);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showBanConfirmationDialog(
      BuildContext context, String driverUserId) async {
    bool confirmBan = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Ban"),
          content: Text("Are you sure you want to ban this driver?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmBan == true) {
      await checkAndHandleBan(driverUserId);
    }
  }

  Widget _buildTruckOrderCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    String orderNumber = data['orderNumber']?.toString() ?? 'No Number';
    String customerName = data['customerName'] ?? 'Ism mavjud emas';
    String fromLocation = data['fromLocation'] ?? 'Unknown';
    String toLocation = data['toLocation'] ?? 'Unknown';
    double cargoWeight = (data['cargoWeight'] as num?)?.toDouble() ?? 0.0;
    String cargoName = data['cargoName'] ?? 'Yuk nomi mavjud emas';
    String orderStatus = data['status'] ?? 'Status mavjud emas';
    DateTime orderTime = (data['orderTime'] as Timestamp).toDate();
    DateTime arrivalTime = orderTime.add(Duration(hours: 8));
    String driverUserId = data['driverUserId'] ?? 'ID mavjud emas';

    // Driver Information
    String driverName = data['driverName'] ?? 'Ism mavjud emas';
    String driverPhoneNumber =
        data['driverPhoneNumber'] ?? 'Telefon raqami mavjud emas';
    String driverTruckModel = data['driverTruckModel'] ?? 'Mashina mavjud emas';
    String driverTruckNumber =
        data['driverTruckNumber'] ?? 'Avtomobil raqami mavjud emas';

    bool isExpanded = expandedStates[doc.id] ?? false;

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
        if (orderStatus == 'qabul qilindi') {
          setState(() {
            expandedStates[doc.id] = !isExpanded;
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
            SizedBox(height: 8),
            Text(
              'Haydovchi ID: $driverUserId',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            ElevatedButton(
              onPressed: () async {
                await showBanConfirmationDialog(context, driverUserId);
              },
              child: Text("Ban Driver"),
            ),
            SizedBox(height: 10),
            if (orderStatus == 'tamomlandi')
              _buildRatingBar(
                  doc.id, driverUserId, driverName, driverPhoneNumber),
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
                        onTap: () => _callDriver(driverPhoneNumber),
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

  Widget _buildRatingBar(String orderId, String driverUserId, String driverName,
      String driverPhoneNumber) {
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
        _saveOrUpdateRating(
            orderId, rating, driverUserId, driverName, driverPhoneNumber);
      },
    );
  }

  Future<void> _saveOrUpdateRating(String orderId, double rating,
      String driverUserId, String driverName, String driverPhoneNumber) async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      if (rating <= 1.0) {
        // Show complaint dialog
        await _showComplaintDialog(orderId, driverUserId, currentUserEmail,
            driverName, driverPhoneNumber);
      } else {
        if (ratingDocIds.containsKey(orderId)) {
          await FirebaseFirestore.instance
              .collection('driverTruckRatings')
              .doc(ratingDocIds[orderId])
              .update({'rating': rating});
        } else {
          DocumentReference docRef = await FirebaseFirestore.instance
              .collection('driverTruckRatings')
              .add({
            'orderId': orderId,
            'rating': rating,
            'ratedBy': currentUserEmail
          });
          setState(() {
            ratingDocIds[orderId] = docRef.id;
          });
        }
      }
    }
  }

  Future<void> _showComplaintDialog(String orderId, String driverUserId,
      String userEmail, String driverName, String driverPhoneNumber) async {
    TextEditingController complaintController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Please describe your issue"),
          content: TextField(
            controller: complaintController,
            maxLines: 3,
            decoration: InputDecoration(hintText: "Describe the issue here"),
          ),
          actions: [
            TextButton(
              child: Text("Submit"),
              onPressed: () async {
                final complaintText = complaintController.text;
                if (complaintText.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('complaints')
                      .add({
                    'orderId': orderId,
                    'driverUserId': driverUserId,
                    'userEmail': userEmail,
                    'driverName': driverName,
                    'driverPhoneNumber': driverPhoneNumber,
                    'complaint': complaintText,
                    'timestamp': DateTime.now(),
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }
}
