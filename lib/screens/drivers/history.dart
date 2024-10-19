import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For formatting date

class DriverOrderHistoryPage extends StatelessWidget {
  const DriverOrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(title: Text('Buyurtmalar Tarixi (Haydovchi)')),
      body: currentUserEmail == null
          ? Center(child: Text('Foydalanuvchi tizimga kirmagan'))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('status', isEqualTo: 'tamomlandi') // Completed orders
                  .where('driverEmail',
                      isEqualTo: currentUserEmail) // Logged-in driver filter
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('Yakunlangan buyurtmalar mavjud emas.'));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return Card(
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text(
                          '${doc['fromLocation']} - ${doc['toLocation']}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Ismi: ${doc['customerName']}'), // Customer's name
                            Text(
                                'Telefon: ${doc['phoneNumber']}'), // Customer's phone
                            Text(
                                'Odamlar soni: ${doc['peopleCount']}'), // People count
                            Text(
                                'Vaqti: ${_formatDate(doc['orderTime'].toDate())}'), // Order time
                            SizedBox(height: 10),
                            Divider(),
                            Text(
                                'Haydovchi: ${doc['driverName']}'), // Driver name
                            Text(
                                'Avtomobil: ${doc['driverCarModel']} (${doc['driverCarNumber']})'), // Car details
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
}
