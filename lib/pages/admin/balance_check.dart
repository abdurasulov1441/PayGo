import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taksi/pages/admin/balance_detail.dart';
import 'package:taksi/style/app_style.dart';

class BalanceRequestsPage extends StatelessWidget {
  const BalanceRequestsPage({super.key});

  Future<Map<String, dynamic>?> _fetchDriverDetails(String userId) async {
    try {
      DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
          .collection('truckdrivers')
          .doc(userId)
          .get();
      return driverSnapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Error fetching driver details: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('status', isEqualTo: 'unchecked')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var transactions = snapshot.data!.docs;

          if (transactions.isEmpty) {
            return Center(
              child: Text(
                'Hozircha so\'rovlar yo\'q',
                style: AppStyle.fontStyle
                    .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              var transaction = transactions[index];
              String userId = transaction['userId'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: _fetchDriverDetails(userId),
                builder: (context, driverSnapshot) {
                  if (!driverSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var driverData = driverSnapshot.data;

                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        driverData != null
                            ? '${driverData['name']} ${driverData['surname']}'
                            : 'Haydovchi topilmadi',
                        style: AppStyle.fontStyle,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${transaction['amount']} UZS'),
                          if (driverData != null)
                            Text(
                              'Aloqa: ${driverData['phone_number']}',
                              style: AppStyle.fontStyle.copyWith(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BalanceDetailPage(transaction.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
