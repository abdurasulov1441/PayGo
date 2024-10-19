import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taksi/style/app_style.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:intl/intl.dart'; // For formatting the date

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  // To keep track of expanded cards
  Map<String, bool> expandedCards = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyurtmalar tarixi', style: AppStyle.fontStyle),
        backgroundColor: AppColors.taxi,
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
              String orderStatus = doc['status'];
              String orderType =
                  doc['orderType'] == 'truck' ? 'yukmashinasi' : 'taksi';
              bool isExpanded = expandedCards[doc.id] ?? false;

              return GestureDetector(
                onTap: () {
                  // Toggle card expansion
                  setState(() {
                    expandedCards[doc.id] = !isExpanded;
                  });
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  color: Colors.white,
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${doc['fromLocation']} - ${doc['toLocation']}',
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildStatusTag(orderStatus),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Turi: $orderType',
                            style: AppStyle.fontStyle.copyWith(
                              fontSize: 14,
                              color: AppColors.taxi,
                            ),
                          ),
                        ),
                        if (orderStatus == 'qabul qilindi') ...[
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.taxi,
                            ),
                          ),
                        ],
                        if (isExpanded && orderStatus == 'qabul qilindi') ...[
                          SizedBox(height: 8),
                          Divider(),
                          _buildDriverDetails(doc),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color backgroundColor;
    String displayStatus;

    if (status == 'kutish jarayonida') {
      backgroundColor = Colors.yellow;
      displayStatus = 'Kutish jarayonida';
    } else if (status == 'qabul qilindi') {
      backgroundColor = Colors.green;
      displayStatus = 'Qabul qilindi';
    } else {
      backgroundColor = Colors.red;
      displayStatus = 'Yopildi';
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Holat: $displayStatus',
        style: AppStyle.fontStyle.copyWith(fontSize: 14),
      ),
    );
  }

  Widget _buildDriverDetails(DocumentSnapshot doc) {
    // Assuming these fields are available in the 'orders' document after the driver accepts the order
    String driverName = doc['driverName'] ?? 'Noma\'lum';
    String driverPhone = doc['driverPhoneNumber'] ?? 'Noma\'lum';
    String vehicleMake = doc['driverCarModel'] ?? 'Noma\'lum';
    String vehicleNumber = doc['driverCarNumber'] ?? 'Noma\'lum';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Haydovchi: $driverName',
          style: AppStyle.fontStyle.copyWith(fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          'Telefon: $driverPhone',
          style: AppStyle.fontStyle.copyWith(fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          'Mashina markasi: $vehicleMake',
          style: AppStyle.fontStyle.copyWith(fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          'Mashina raqami: $vehicleNumber',
          style: AppStyle.fontStyle.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}
