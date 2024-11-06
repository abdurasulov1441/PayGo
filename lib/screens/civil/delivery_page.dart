import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taksi/style/app_style.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  String? selectedFrom;
  String? selectedTo;

  List<String> locations = []; // Regions from Firestore
  List<DocumentSnapshot> truckDrivers = [];
  List<DocumentSnapshot> allDrivers = []; // Full list of drivers
  Map<String, double> driverRatings = {}; // To store average rating per driver

  @override
  void initState() {
    super.initState();
    fetchRegions(); // Fetch regions from Firestore
    fetchTruckDrivers(); // Fetch truck drivers from Firestore
  }

  Future<void> fetchRegions() async {
    final regionsSnapshot = await FirebaseFirestore.instance
        .collection('data')
        .doc('regions')
        .get();

    final fetchedLocations =
        List<String>.from(regionsSnapshot['regions'] ?? []);

    setState(() {
      locations = fetchedLocations;
    });
  }

  Future<void> fetchTruckDrivers() async {
    final drivers =
        await FirebaseFirestore.instance.collection('truckdrivers').get();

    setState(() {
      allDrivers = drivers.docs;
      truckDrivers = allDrivers;
    });

    fetchDriverRatings();
  }

  Future<void> fetchDriverRatings() async {
    final ratingsSnapshot =
        await FirebaseFirestore.instance.collection('driverRatings').get();

    Map<String, List<double>> ratingData = {};

    for (var doc in ratingsSnapshot.docs) {
      final driverEmail = doc['driverEmail'];
      final rating = doc['rating'].toDouble();

      if (ratingData.containsKey(driverEmail)) {
        ratingData[driverEmail]!.add(rating);
      } else {
        ratingData[driverEmail] = [rating];
      }
    }

    Map<String, double> calculatedRatings = {};
    ratingData.forEach((driverEmail, ratings) {
      final averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
      calculatedRatings[driverEmail] = averageRating;
    });

    setState(() {
      driverRatings = calculatedRatings;
    });
  }

  void showRegionBottomSheet(BuildContext context, bool isFrom) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: locations.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(locations[index]),
              onTap: () {
                setState(() {
                  if (isFrom) {
                    selectedFrom = locations[index];
                  } else {
                    selectedTo = locations[index];
                  }
                  filterDrivers();
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void filterDrivers() {
    setState(() {
      truckDrivers = allDrivers.where((doc) {
        final driverFrom = doc['from'].toString().toLowerCase();
        final driverTo = doc['to'].toString().toLowerCase();

        if (selectedFrom != null && selectedTo != null) {
          return (driverFrom == selectedFrom!.toLowerCase() &&
                  driverTo == selectedTo!.toLowerCase()) ||
              (driverFrom == selectedTo!.toLowerCase() &&
                  driverTo == selectedFrom!.toLowerCase());
        }

        if (selectedFrom != null) {
          return driverFrom == selectedFrom!.toLowerCase() ||
              driverTo == selectedFrom!.toLowerCase();
        }

        if (selectedTo != null) {
          return driverFrom == selectedTo!.toLowerCase() ||
              driverTo == selectedTo!.toLowerCase();
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Text('Yuk Haydovchilari',
            style: AppStyle.fontStyle.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showRegionBottomSheet(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      selectedFrom ?? 'Qayerdan',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      showRegionBottomSheet(context, false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      selectedTo ?? 'Qayerga',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: truckDrivers.length,
              itemBuilder: (context, index) {
                final driver = truckDrivers[index];
                final driverEmail = driver['email'];
                final averageRating = driverRatings.containsKey(driverEmail)
                    ? driverRatings[driverEmail]!.toStringAsFixed(1)
                    : 'Baho yo\'q';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  shadowColor: Colors.grey.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/truck.png',
                              width: 60,
                              height: 60,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driver['name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Mashina raqami: ${driver['truck_number']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.orange, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    averageRating,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(color: Colors.grey[300]),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildInfoText('Qayerdan:', driver['from']),
                            Icon(Icons.arrow_forward,
                                color: Colors.teal, size: 20),
                            buildInfoText('Qayerga:', driver['to']),
                          ],
                        ),
                        SizedBox(height: 10),
                        buildInfoText('Mashina modeli:', driver['truck_model']),
                        buildInfoText(
                            'Telefon raqami:', driver['phone_number']),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
