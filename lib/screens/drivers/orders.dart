import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For formatting the date

class BuyurtmalarPage extends StatefulWidget {
  const BuyurtmalarPage({super.key});

  @override
  _BuyurtmalarPageState createState() => _BuyurtmalarPageState();
}

class _BuyurtmalarPageState extends State<BuyurtmalarPage> {
  String driverRegion = 'Namangan'; // Example: driver region
  String driverVehicleType = 'Mashina'; // 'Mashina' or 'Truck'

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  Future<void> _fetchDriverData() async {
    // Fetch driver data based on logged-in user's email
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    final snapshot = await FirebaseFirestore.instance
        .collection('driver')
        .where('email', isEqualTo: userEmail)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final driverData = snapshot.docs.first.data();
      setState(() {
        driverRegion = driverData['to']; // Example: Namangan
        driverVehicleType = driverData['vehicleType']; // 'Mashina' or 'Truck'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Buyurtmalar')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('fromLocation', isEqualTo: driverRegion)
            .where('orderType',
                isEqualTo: driverVehicleType == 'Mashina' ? 'taksi' : 'truck')
            .where('status',
                isEqualTo: 'kutish jarayonida') // Show only pending orders
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(
                    '${doc['fromLocation']} - ${doc['toLocation']}', // No "Buyurtma"
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Ismi: ${doc['customerName']}'), // Display customer's name
                      Text(
                        'Vaqti: ${_formatDate(doc['orderTime'].toDate())}', // Display formatted order time
                      ),
                      if (doc['orderType'] == 'taksi') ...[
                        Text(
                            'Odamlar soni: ${doc['peopleCount']}'), // Show people count for taxi orders
                      ],
                      if (doc['orderType'] == 'truck') ...[
                        Text(
                            'Yuk nomi: ${doc['cargoName']}'), // Show cargo name for truck orders
                        Text(
                            'Yuk og\'irligi: ${doc['cargoWeight']} kg'), // Show cargo weight
                      ],
                    ],
                  ),
                  trailing: doc['status'] == 'kutish jarayonida'
                      ? ElevatedButton(
                          onPressed: () => _acceptOrder(doc.id),
                          child: Text('Qabul qilish'),
                        )
                      : null, // No button if already accepted
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // Function to format the order time
  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  // Function to accept an order
  Future<void> _acceptOrder(String orderId) async {
    // Fetch driver's data
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    final snapshot = await FirebaseFirestore.instance
        .collection('driver')
        .where('email', isEqualTo: userEmail)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final driverData = snapshot.docs.first.data();

      // Update the order with the driver's details
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'qabul qilindi',
        'driverName': driverData['name'],
        'driverPhoneNumber': driverData['phoneNumber'],
        'driverCarModel': driverData['carModel'],
        'driverCarNumber': driverData['carNumber'],
        'driverEmail': driverData['email'], // Hidden, but saved
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Buyurtma qabul qilindi!')),
      );
    }
  }
}
