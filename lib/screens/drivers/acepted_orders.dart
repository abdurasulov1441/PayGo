import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting date
import 'package:url_launcher/url_launcher.dart'; // For phone call functionality

class AcceptedOrdersPage extends StatelessWidget {
  const AcceptedOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Qabul qilingan buyurtmalar')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'qabul qilindi') // Only accepted orders
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${doc['fromLocation']} - ${doc['toLocation']}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Ismi: ${doc['customerName']}'), // Customer's name
                      Text(
                        'Telefon: ${doc['phoneNumber']}', // Passenger's phone number
                      ),
                      Text(
                        'Odamlar soni: ${doc['peopleCount']}', // People count
                      ),
                      Text(
                        'Vaqti: ${_formatDate(doc['orderTime'].toDate())}', // Order time
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () => _returnOrder(doc.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red, // Red for "Return Order"
                            ),
                            child: Text('Qaytarish'), // Return Order
                          ),
                          ElevatedButton(
                            onPressed: () => _callPassenger(doc['phoneNumber']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Blue for "Call"
                            ),
                            child: Text('Qo\'ng\'iroq'), // Call
                          ),
                          ElevatedButton(
                            onPressed: () => _completeOrder(doc.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.green, // Green for "Complete Order"
                            ),
                            child: Text('Tugatish'), // Complete Order
                          ),
                        ],
                      ),
                    ],
                  ),
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

  // Function to return the order
  Future<void> _returnOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'kutish jarayonida', // Set status back to pending
      'driverName': null, // Remove driver details
      'driverPhoneNumber': null,
      'driverCarModel': null,
      'driverCarNumber': null,
      'driverEmail': null,
    });
    print('Order returned to pending status.');
  }

  // Function to initiate a phone call to the passenger
  void _callPassenger(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch phone call to $phoneNumber');
    }
  }

  // Function to complete the order
  Future<void> _completeOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': 'tamomlandi', // Set status to completed
    });
    print('Order marked as completed.');
  }
}
