import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
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
  bool hasActiveOrder = false; // To check if the driver has an active order
  List<String> regions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkActiveOrder();
    _fetchRegions();
  }

  Future<void> _checkActiveOrder() async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser!.email;

      // Проверка наличия активного заказа у водителя
      final activeOrdersSnapshot = await FirebaseFirestore.instance
          .collection('truck_orders')
          .where('accepted_by', isEqualTo: userEmail)
          .where('status', isEqualTo: 'qabul qilindi')
          .get();

      if (activeOrdersSnapshot.docs.isNotEmpty) {
        setState(() {
          hasActiveOrder = true;
        });
      }
    } catch (e) {
      print("Error checking active order: $e");
    }
  }

  Future<void> _fetchRegions() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('data')
          .doc('regions')
          .get();
      if (snapshot.exists) {
        setState(() {
          regions = List<String>.from(snapshot['regions']);
          isLoading = false;
        });
      }
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

      // Получаем userId водителя по его email
      final snapshot = await FirebaseFirestore.instance
          .collection('truckdrivers')
          .where('email', isEqualTo: userEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final String userId = snapshot.docs.first.id;

        // Обновляем только поля `accepted_by` и `status` в заказе
        await FirebaseFirestore.instance
            .collection('truck_orders')
            .doc(orderId)
            .update({
          'status': 'qabul qilindi',
          'accepted_by': userId, // Присваиваем userId водителя
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Buyurtma qabul qilindi!')),
        );

        setState(() {
          hasActiveOrder = true; // Обновляем статус активного заказа
        });
      } else {
        print('Driver not found');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Haydovchi topilmadi!')),
        );
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
      query = query.where('from', isEqualTo: selectedFromRegion);
    }
    if (selectedToRegion != null && selectedToRegion!.isNotEmpty) {
      query = query.where('to', isEqualTo: selectedToRegion);
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
    final orderNumber = doc.id; // Используем ID документа как номер заказа
    final fromLocation = doc['from'] ?? 'Unknown';
    final toLocation = doc['to'] ?? 'Unknown';
    final cargoWeight = doc['cargo_weight'] ?? 0.0;
    final cargoName = doc['cargo_name'] ?? 'Unknown';
    final orderTime = (doc['accept_time'] as Timestamp).toDate();

    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: hasActiveOrder
          ? _buildOrderCardContent(orderNumber, fromLocation, toLocation,
              cargoWeight, cargoName, orderTime)
          : Dismissible(
              key: Key(doc.id),
              direction: DismissDirection.startToEnd,
              background: _buildSwipeActionBackground(),
              onDismissed: (direction) {
                _acceptOrder(doc.id);
              },
              child: _buildOrderCardContent(orderNumber, fromLocation,
                  toLocation, cargoWeight, cargoName, orderTime),
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
      String orderNumber,
      String fromLocation,
      String toLocation,
      double cargoWeight,
      String cargoName,
      DateTime orderTime) {
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
      backgroundColor: Colors.white,
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
          ? Center(
              child: LottieBuilder.asset('assets/lottie/loading.json'),
            )
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
