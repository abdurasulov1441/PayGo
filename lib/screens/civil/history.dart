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
  Map<String, double> orderRatings =
      {}; // Map to store the rating for each order
  Map<String, String> ratingDocIds =
      {}; // Map to store the document ID of the rating

  @override
  void initState() {
    super.initState();
    _loadRatings(); // Load previously saved ratings
  }

  // Fetch saved ratings from Firestore for the current user
  Future<void> _loadRatings() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('driverRatings')
          .where('ratedBy', isEqualTo: currentUserEmail)
          .get();

      setState(() {
        for (var doc in ratingsSnapshot.docs) {
          orderRatings[doc['orderId']] = doc['rating'].toDouble();
          ratingDocIds[doc['orderId']] =
              doc.id; // Store the document ID to update later
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
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

  // Building the order card
  Widget _buildOrderCard(DocumentSnapshot doc) {
    String orderId = doc.id;

    // Check if 'orderNumber' field exists and provide a default value
    String orderNumber =
        (doc.data() as Map<String, dynamic>).containsKey('orderNumber')
            ? doc['orderNumber'].toString()
            : 'No Number'; // Default value if 'orderNumber' doesn't exist

    String customerName = doc['customerName'];
    String fromLocation = doc['fromLocation'];
    String toLocation = doc['toLocation'];
    String orderStatus = doc['status'];
    int peopleCount = doc['peopleCount'];
    DateTime orderTime = (doc['orderTime'] as Timestamp).toDate();
    DateTime arrivalTime = orderTime.add(Duration(hours: 8));

    String driverEmail =
        (doc.data() as Map<String, dynamic>).containsKey('driverEmail')
            ? doc['driverEmail']
            : 'N/A'; // Default if driverEmail doesn't exist

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
                    _buildStatusTag(orderStatus), // Status below the date
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
              'Odamlar soni: $peopleCount',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 10),
            if (orderStatus == 'tamomlandi')
              _buildRatingBar(
                  orderId, driverEmail), // Star Rating for completed orders
          ],
        ),
      ),
    );
  }

  // Displaying the order number with a tag
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

  // Displaying the status tag below the date
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

  // Building the from-to location row
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

  // Building the rating bar for completed orders
  Widget _buildRatingBar(String orderId, String driverEmail) {
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
        _saveOrUpdateRating(orderId, driverEmail, rating);
      },
    );
  }

  // Function to save or update the rating in Firestore
  Future<void> _saveOrUpdateRating(
      String orderId, String driverEmail, double rating) async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail != null) {
      // Check if the rating already exists in the database
      if (ratingDocIds.containsKey(orderId)) {
        // Update the existing rating document
        await FirebaseFirestore.instance
            .collection('driverRatings')
            .doc(ratingDocIds[orderId])
            .update({
          'rating': rating,
        });
      } else {
        // Save a new rating document in Firestore
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('driverRatings').add({
          'orderId': orderId,
          'driverEmail': driverEmail,
          'rating': rating,
          'ratedBy': currentUserEmail,
        });

        // Store the new document ID for future updates
        setState(() {
          ratingDocIds[orderId] = docRef.id;
        });
      }
    }
  }

  // Function to format the order time
  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }
}
