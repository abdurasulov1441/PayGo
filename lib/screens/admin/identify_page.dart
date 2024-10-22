import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taksi/screens/admin/identify_detail.dart';
import 'package:taksi/style/app_style.dart';

class AccountVerificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('driver')
            .where('status', isEqualTo: 'unidentified')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var drivers = snapshot.data!.docs;

          if (drivers.isEmpty) {
            return Center(
                child: Text('Hozircha tekshirilmagan haydovchi yo\'q.'));
          }

          return ListView.builder(
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              var driver = drivers[index];
              return Card(
                child: ListTile(
                  title: Text(driver['name'] + ' ' + driver['lastName']),
                  subtitle: Text(driver['phoneNumber']),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(driver.id),
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
