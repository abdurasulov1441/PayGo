import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  Map<String, double> orderRatings = {};
  Map<String, String> ratingDocIds = {};

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('taxiDriverRatings')
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
          'Buyurtmalar tarixi',
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('taxi_orders')
            .where('userEmail',
                isEqualTo: userEmail) // Filter by userEmail for passenger
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((doc) {
              return _buildOrderCard(doc);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(DocumentSnapshot doc) {
    String orderId = doc.id;
    String orderNumber =
        (doc.data() as Map<String, dynamic>).containsKey('orderNumber')
            ? doc['orderNumber'].toString()
            : 'No Number';
    String orderType = doc['orderType'] ?? 'unknown';
    String customerName = doc['customerName'] ?? 'Ism mavjud emas';
    String fromLocation = doc['fromLocation'] ?? 'Unknown';
    String toLocation = doc['toLocation'] ?? 'Unknown';
    String orderStatus = doc['status'] ?? 'Unknown';
    DateTime orderTime = (doc['orderTime'] as Timestamp).toDate();
    DateTime arrivalTime = orderTime.add(Duration(hours: 8));

    Widget additionalInfo;

    if (orderType == 'taksi') {
      int peopleCount = doc['peopleCount'];
      additionalInfo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customerName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Odamlar soni: $peopleCount',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      );
    } else if (orderType == 'truck') {
      double cargoWeight = doc['cargoWeight'] ?? 0.0;
      String cargoName = doc['cargoName'] ?? 'Yuk nomi mavjud emas';
      additionalInfo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customerName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Yuk vazni: ${cargoWeight.toStringAsFixed(2)} kg',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          SizedBox(height: 8),
          Text(
            'Yuk nomi: $cargoName',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      );
    } else {
      additionalInfo = Text(
        'Order type unknown',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
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
                    SizedBox(height: 4),
                    _buildStatusTag(orderStatus),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            additionalInfo,
            SizedBox(height: 10),
            _buildLocationRow(fromLocation, toLocation, orderTime, arrivalTime),
            SizedBox(height: 10),
            if (orderStatus == 'tamomlandi') _buildRatingBar(orderId),
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

  Widget _buildStatusTag(String status) {
    Color backgroundColor;
    String displayStatus;

    if (status == 'tamomlandi') {
      backgroundColor = Colors.green;
      displayStatus = 'Tamomlandi';
    } else if (status == 'qabul qilindi') {
      backgroundColor = Colors.orange;
      displayStatus = 'Qabul qilindi';
    } else {
      backgroundColor = Colors.red;
      displayStatus = 'Kutish jarayonida';
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
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
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
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
            .collection('taxiDriverRatings')
            .doc(ratingDocIds[orderId])
            .update({
          'rating': rating,
        });
      } else {
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('taxiDriverRatings')
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
