import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taksi/screens/admin/balance_detail.dart';
import 'package:taksi/style/app_style.dart';

class BalanceRequestsPage extends StatelessWidget {
  const BalanceRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              return Card(
                color: Colors.white,
                child: ListTile(
                  title: Text(
                      '${transaction['firstName']} ${transaction['lastName']}'),
                  subtitle: Text('${transaction['amount']} UZS'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BalanceDetailPage(transaction.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
