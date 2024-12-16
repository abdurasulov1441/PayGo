import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class BuyurtmalarPage extends StatefulWidget {
  const BuyurtmalarPage({super.key});

  @override
  _BuyurtmalarPageState createState() => _BuyurtmalarPageState();
}

class _BuyurtmalarPageState extends State<BuyurtmalarPage> {
  String? selectedFromRegion;
  String? selectedToRegion;
  String? driverRegion;
  String? subscriptionPlan;
  List<String> regions = [];
  bool isLoading = true;
  bool filterToshkentSamarkand = false;
  bool isReverseFilter = false;
  bool isFilterReversed = false;

  void _toggleFilter() {
    setState(() {
      isFilterReversed = !isFilterReversed;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
    _fetchRegions();
  }

  Future<void> _acceptOrder(String orderId) async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email;
      final snapshot = await FirebaseFirestore.instance
          .collection('taxidrivers')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final driverData = snapshot.docs.first.data();

        await FirebaseFirestore.instance
            .collection('taxi_orders')
            .doc(orderId)
            .update({
          'status': 'qabul qilindi',
          'acceptedBy': driverData['email'],
          'driverEmail': driverData['email'], // Make sure this is updated
          'driverName': driverData['name'],
          'driverLastName': driverData['lastName'],
          'driverPhoneNumber': driverData['phoneNumber'],
          'driverCarModel': driverData['carModel'],
          'driverCarNumber': driverData['carNumber'],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Buyurtma qabul qilindi!')),
        );
      }
    } catch (e) {
      print("Error accepting order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik yuz berdi!')),
      );
    }
  }

  Future<void> _fetchDriverData() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email;
      final snapshot = await FirebaseFirestore.instance
          .collection('taxidrivers')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final driverData = snapshot.docs.first.data();
        setState(() {
          driverRegion =
              driverData['from'] ?? ''; // Use the 'from' region dynamically
          selectedToRegion =
              driverData['to'] ?? ''; // Use the 'to' region dynamically
          subscriptionPlan = driverData['subscription_plan'];
        });
        print(driverData['from']);
        print(driverData['to']);
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

  Widget _buildRegionDropdown({
    required String label,
    required String? selectedRegion,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      value: selectedRegion,
      items: regions.map((region) {
        return DropdownMenuItem<String>(
          value: region,
          child: Text(region),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Stream<QuerySnapshot> _fetchOrders() {
    final fromLocation = isFilterReversed ? 'Toshkent sh' : driverRegion!;
    final toLocation = isFilterReversed ? driverRegion! : 'Toshkent sh';

    // Fetch orders where fromLocation and toLocation match the required regions
    final fromQuery = FirebaseFirestore.instance
        .collection('taxi_orders')
        .where('fromLocation', isEqualTo: fromLocation)
        .where('toLocation', isEqualTo: toLocation)
        .where('status', isEqualTo: 'kutish jarayonida')
        .snapshots();
    print("Fetching orders from: $fromLocation to: $toLocation");

    return fromQuery;
  }

  Future<List<QueryDocumentSnapshot>> _fetchOrdersByRegion(
      String fromRegion, String toRegion) async {
    final fromLocationQuery = await FirebaseFirestore.instance
        .collection('taxi_orders')
        .where('status', isEqualTo: 'kutish jarayonida')
        .where('fromLocation', isEqualTo: fromRegion)
        .where('toLocation', isEqualTo: toRegion)
        .get();

    return fromLocationQuery.docs;
  }

  bool filterReversed = false;

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
    final customerName = doc['customerName'] ?? 'Unknown'; // Имя клиента
    final fromLocation = doc['fromLocation'] ?? 'Unknown';
    final toLocation = doc['toLocation'] ?? 'Unknown';
    final peopleCount = doc['peopleCount'] ?? 0; // Количество людей
    final orderTime = (doc['orderTime'] as Timestamp).toDate();
    final arrivalTime = orderTime.add(Duration(hours: 8));

    return Dismissible(
      key: Key(doc.id),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.check, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) {
        _acceptOrder(doc.id); // Принятие заказа при свайпе
      },
      child: Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
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
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                customerName, // Имя клиента
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
              Text('Odamlar soni: $peopleCount'), // Количество людей
            ],
          ),
        ),
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
            icon: Icon(
                isFilterReversed ? Icons.filter_alt_off : Icons.filter_alt),
            onPressed: _toggleFilter, // Toggle the filter when pressed
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (subscriptionPlan != 'Vaqtinchalik') ...[
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: _buildRegionDropdown(
                    //         label: 'Qayerdan',
                    //         selectedRegion: selectedFromRegion,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             selectedFromRegion = value;
                    //           });
                    //         },
                    //       ),
                    //     ),
                    //     SizedBox(width: 10),
                    //     Expanded(
                    //       child: _buildRegionDropdown(
                    //         label: 'Qayerga',
                    //         selectedRegion: selectedToRegion,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             selectedToRegion = value;
                    //           });
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 20),
                  ],
                  Expanded(child: _buildOrderStream()),
                ],
              ),
            ),
    );
  }
}
