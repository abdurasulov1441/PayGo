import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TruckOrdersPage extends StatefulWidget {
  const TruckOrdersPage({super.key});

  @override
  _TruckOrdersPageState createState() => _TruckOrdersPageState();
}

class _TruckOrdersPageState extends State<TruckOrdersPage> {
  String? selectedFromRegion;
  String? selectedToRegion;
  String? driverRegion;
  String? subscriptionPlan;
  bool hasActiveOrder = false; // To check if the driver has an active order
  List<String> regions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
    _fetchRegions();
  }

  Future<void> _fetchDriverData() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email;

      // Check if the driver has any active orders
      final activeOrdersSnapshot = await FirebaseFirestore.instance
          .collection('truck_orders')
          .where('driverEmail', isEqualTo: userEmail)
          .where('status', isEqualTo: 'qabul qilindi')
          .get();

      if (activeOrdersSnapshot.docs.isNotEmpty) {
        setState(() {
          hasActiveOrder = true;
        });
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('truckdrivers')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final driverData = snapshot.docs.first.data();
        setState(() {
          driverRegion = driverData['from'] ?? '';
          selectedToRegion = null; // Reset selected region
          subscriptionPlan = driverData['subscription_plan'];
        });
      }
    } catch (e) {
      print("Error fetching driver data: $e");
    }
  }

  Future<void> _fetchRegions() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('regions').get();
      setState(() {
        regions = snapshot.docs.map((doc) => doc['region'].toString()).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching regions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _acceptOrder(String orderId) async {
    if (hasActiveOrder) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Sizda faol buyurtma mavjud. Yangi buyurtma qabul qilolmaysiz.'),
        ),
      );
      return;
    }

    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email;

      final snapshot = await FirebaseFirestore.instance
          .collection('truckdrivers')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final driverData = snapshot.docs.first.data();

        // Update order with driver information
        final String truckNumber =
            driverData['TruckNumber'] ?? 'Avtomobil raqami mavjud emas';

        await FirebaseFirestore.instance
            .collection('truck_orders')
            .doc(orderId)
            .update({
          'status': 'qabul qilindi',
          'acceptedBy': driverData['email'],
          'driverEmail': driverData['email'],
          'driverName': driverData['name'],
          'driverPhoneNumber': driverData['phoneNumber'],
          'driverTruckModel': driverData['truckModel'],
          'driverTruckNumber': truckNumber, // Save truck number
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Buyurtma qabul qilindi!')),
        );

        setState(() {
          hasActiveOrder = true; // Mark active order status
        });
      } else {
        print('Driver not found');
      }
    } catch (e) {
      print("Error accepting order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik yuz berdi!')),
      );
    }
  }

  Stream<QuerySnapshot> _fetchOrders() {
    Query query = FirebaseFirestore.instance
        .collection('truck_orders')
        .where('status', isEqualTo: 'kutish jarayonida');

    if (selectedFromRegion != null && selectedFromRegion!.isNotEmpty) {
      query = query.where('fromLocation', isEqualTo: selectedFromRegion);
    }
    if (selectedToRegion != null && selectedToRegion!.isNotEmpty) {
      query = query.where('toLocation', isEqualTo: selectedToRegion);
    }

    return query.snapshots();
  }

  Widget _buildOrderStream() {
    return StreamBuilder(
      stream: _fetchOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Buyurtmalar mavjud emas'));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return _buildOrderCard(doc);
          }).toList(),
        );
      },
    );
  }

  Widget _buildOrderCard(QueryDocumentSnapshot doc) {
    final orderNumber = doc['orderNumber'] ?? 'Unknown';
    final customerName = doc['customerName'] ?? 'Unknown';
    final fromLocation = doc['fromLocation'] ?? 'Unknown';
    final toLocation = doc['toLocation'] ?? 'Unknown';
    final cargoWeight = doc['cargoWeight'] ?? 0.0;
    final cargoName = doc['cargoName'] ?? 'Unknown';
    final orderTime = (doc['orderTime'] as Timestamp).toDate();
    final arrivalTime = orderTime.add(Duration(hours: 8));

    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: hasActiveOrder
          ? _buildOrderCardContent(orderNumber, customerName, fromLocation,
              toLocation, cargoWeight, cargoName, orderTime, arrivalTime)
          : Dismissible(
              key: Key(doc.id),
              direction: DismissDirection.startToEnd,
              background: _buildSwipeActionBackground(),
              onDismissed: (direction) {
                _acceptOrder(doc.id); // Accept the order on swipe
              },
              child: _buildOrderCardContent(
                  orderNumber,
                  customerName,
                  fromLocation,
                  toLocation,
                  cargoWeight,
                  cargoName,
                  orderTime,
                  arrivalTime),
            ),
    );
  }

  Widget _buildSwipeActionBackground() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.white, size: 30),
          SizedBox(width: 10),
          Text(
            'Qabul qilish',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCardContent(
      int orderNumber,
      String customerName,
      String fromLocation,
      String toLocation,
      double cargoWeight,
      String cargoName,
      DateTime orderTime,
      DateTime arrivalTime) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Buyurtma №$orderNumber',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Spacer(),
              Text(
                _formatDate(orderTime),
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            customerName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Qayerdan:',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text(fromLocation,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(_formatDate(orderTime),
                        style: TextStyle(color: Colors.grey)),
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(_formatDate(arrivalTime),
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('Yuk nomi: $cargoName'),
          SizedBox(height: 5),
          Text('Yuk vazni: $cargoWeight kg'),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Buyurtmalar',
          style: AppStyle.fontStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.taxi,
        actions: [
          IconButton(
            icon: Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              setState(() {
                selectedFromRegion = null;
                selectedToRegion = null;
              });
            },
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildLocationSelector(
                    label: 'Qayerdan',
                    location: selectedFromRegion ?? '',
                    onSelected: (selectedLocation) {
                      setState(() {
                        selectedFromRegion = selectedLocation;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  _buildLocationSelector(
                    label: 'Qayerga',
                    location: selectedToRegion ?? '',
                    onSelected: (selectedLocation) {
                      setState(() {
                        selectedToRegion = selectedLocation;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Expanded(child: _buildOrderStream()),
                ],
              ),
            ),
    );
  }

  Widget _buildLocationSelector({
    required String label,
    required String location,
    required ValueChanged<String> onSelected,
  }) {
    return GestureDetector(
      onTap: () => _showLocationBottomSheet(onSelected),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$label: $location', style: AppStyle.fontStyle),
            Icon(Icons.arrow_drop_down, color: AppColors.taxi),
          ],
        ),
      ),
    );
  }

  void _showLocationBottomSheet(Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Manzilni tanlang',
                  style: AppStyle.fontStyle.copyWith(fontSize: 18),
                ),
                Divider(),
                ...regions.map((region) => ListTile(
                      title: Text(region, style: AppStyle.fontStyle),
                      onTap: () {
                        onSelected(region);
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
