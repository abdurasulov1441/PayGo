import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taksi/services/order_statistic_widget.dart';

import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class OrderStatisticsPage extends StatefulWidget {
  const OrderStatisticsPage({super.key});

  @override
  _OrderStatisticsPageState createState() => _OrderStatisticsPageState();
}

class _OrderStatisticsPageState extends State<OrderStatisticsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchOrderId;

  void _searchOrder(String orderId) {
    setState(() {
      _searchOrderId = orderId;
    });
  }

  Widget _buildOrderCard(DocumentSnapshot orderDoc) {
    final orderData = orderDoc.data() as Map<String, dynamic>;
    final orderId = orderDoc.id;
    final fromLocation = orderData['from'];
    final toLocation = orderData['to'];
    final cargoName = orderData['cargo_name'];
    final cargoWeight = orderData['cargo_weight'];
    final status = orderData['status'];
    final passengerId = orderData['user_id'] ?? 'Unknown';
    final driverId = orderData['accepted_by'] ?? 'Not Accepted';

    // Passenger and Driver Data from Collections
    Future<Map<String, dynamic>?> fetchUserData(
        String id, String collection) async {
      final docSnapshot =
          await FirebaseFirestore.instance.collection(collection).doc(id).get();
      return docSnapshot.data();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: Future.wait([
        fetchUserData(passengerId, 'user'), // Passenger data
        if (driverId != 'Not Accepted')
          fetchUserData(driverId, 'truckdrivers') // Driver data if available
      ]).then((data) {
        return {
          'passengerData': data.isNotEmpty ? data[0] : null,
          'driverData': data.length > 1 ? data[1] : null,
        };
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final passengerData = snapshot.data?['passengerData'];
        final driverData = snapshot.data?['driverData'];

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Buyurtma ID: $orderId',
                      style: AppStyle.fontStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.taxi,
                      ),
                    ),
                    Text(
                      'Holat: $status',
                      style: AppStyle.fontStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 1, height: 20),

                // Passenger and Driver Information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Yo\'lovchi ID: $passengerId',
                            style: AppStyle.fontStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            'Yo\'lovchi: ${passengerData?['name'] ?? 'Noma\'lum'} ${passengerData?['surname'] ?? ''}',
                            style: AppStyle.fontStyle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Aloqa: ${passengerData?['phone_number'] ?? 'N/A'}',
                            style: AppStyle.fontStyle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Haydovchi ID: $driverId',
                            style: AppStyle.fontStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            driverId == 'Not Accepted'
                                ? 'Haligacha qabul qilinmagan'
                                : 'Haydovchi: ${driverData?['name'] ?? ''} ${driverData?['surname'] ?? ''}',
                            style: AppStyle.fontStyle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            driverId == 'Not Accepted'
                                ? ''
                                : 'Aloqa: ${driverData?['phone_number'] ?? 'N/A'}',
                            style: AppStyle.fontStyle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(thickness: 1, height: 20),

                // Order Details with Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Qayerdan: $fromLocation',
                        style: AppStyle.fontStyle.copyWith(
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.grey),
                    Expanded(
                      child: Text(
                        'Qayerga: $toLocation',
                        style: AppStyle.fontStyle.copyWith(
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Vehicle Details if Driver Accepted
                if (driverId != 'Not Accepted') ...[
                  Divider(thickness: 1, height: 20),
                  Text(
                    'Haydovchi mashinasi: ${driverData?['truck_number'] ?? 'N/A'} - ${driverData?['truck_model'] ?? 'N/A'}',
                    style: AppStyle.fontStyle.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],

                // Cargo Information
                Divider(thickness: 1, height: 20),
                Text(
                  'Yuk nomi: $cargoName (${cargoWeight}kg)',
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getOrderDetails(
      String userId, String? acceptedById) async {
    final passengerData = await FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .get()
        .then((doc) => doc.data());
    final driverData = acceptedById != null
        ? await FirebaseFirestore.instance
            .collection('truckdrivers')
            .doc(acceptedById)
            .get()
            .then((doc) => doc.data())
        : null;
    return {
      'passengerData': passengerData,
      'driverData': driverData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OrderStatisticsWidget(),
            SizedBox(height: 20),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buyurtma ID bo\'yicha qidirish',
                prefixIcon: Icon(Icons.search, color: AppColors.taxi),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.taxi),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.taxi),
                ),
              ),
              onSubmitted: _searchOrder,
            ),
            SizedBox(height: 20),

            // Order list on search only
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _searchOrderId != null && _searchOrderId!.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection('truck_orders')
                        .where(FieldPath.documentId, isEqualTo: _searchOrderId)
                        .snapshots()
                    : null,
                builder: (context, snapshot) {
                  if (_searchOrderId == null || _searchOrderId!.isEmpty) {
                    return Center(
                        child: Text('Search for orders by ID.',
                            style: AppStyle.fontStyle));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('Buyurtmalar topilmadi.',
                            style: AppStyle.fontStyle));
                  }

                  return ListView(
                    children: snapshot.data!.docs
                        .map((doc) => _buildOrderCard(doc))
                        .toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
