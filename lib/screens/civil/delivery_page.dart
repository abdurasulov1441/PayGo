import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  _DeliveryPageState createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  String? selectedFrom;
  String? selectedTo;

  List<DocumentSnapshot> truckDrivers = [];
  List<DocumentSnapshot> allTruckDrivers = []; // Full list of truck drivers
  List<String> locations = []; // Will be filled with regions from Firestore
  bool isLoadingRegions = true; // Track loading state for regions

  @override
  void initState() {
    super.initState();
    fetchRegions(); // Fetch regions from Firestore
    fetchTruckDrivers(); // Fetch truck drivers from Firestore
  }

  // Fetch regions from Firestore
  Future<void> fetchRegions() async {
    final regionsSnapshot =
        await FirebaseFirestore.instance.collection('regions').get();

    final fetchedLocations =
        regionsSnapshot.docs.map((doc) => doc['region'].toString()).toList();

    setState(() {
      locations = fetchedLocations;
      isLoadingRegions = false; // Finished loading regions
    });
  }

  // Fetch truck drivers from Firestore
  Future<void> fetchTruckDrivers() async {
    final drivers = await FirebaseFirestore.instance
        .collection('driver')
        .where('vehicleType', isEqualTo: 'Yuk mashinasi')
        .get();
    setState(() {
      allTruckDrivers = drivers.docs; // Full list of truck drivers
      truckDrivers = allTruckDrivers; // Initially show all truck drivers
    });
  }

  // Filter drivers based on selected "Qayerdan" and "Qayerga"
  void filterDrivers() {
    if (selectedFrom != null && selectedTo != null) {
      setState(() {
        truckDrivers = allTruckDrivers.where((doc) {
          final from = doc['from'].toLowerCase();
          final to = doc['to'].toLowerCase();

          // Filter by checking both directions (from-to and to-from)
          return (from == selectedFrom!.toLowerCase() &&
                  to == selectedTo!.toLowerCase()) ||
              (from == selectedTo!.toLowerCase() &&
                  to == selectedFrom!.toLowerCase());
        }).toList();
      });
    } else {
      setState(() {
        truckDrivers = allTruckDrivers; // Reset to show all truck drivers
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gruzovik Haydovchilari',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 5,
        centerTitle: true, // Center the title
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Show a loading spinner while regions are being fetched
                if (isLoadingRegions)
                  Center(child: CircularProgressIndicator())
                else ...[
                  // Dropdown for "Qayerdan"
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Qayerdan',
                      labelStyle: TextStyle(color: Colors.teal, fontSize: 16),
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: selectedFrom,
                    items: locations.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFrom = value;
                      });
                      filterDrivers();
                    },
                    isExpanded: true, // Full width
                  ),
                  const SizedBox(height: 10),
                  // Dropdown for "Qayerga"
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Qayerga',
                      labelStyle: TextStyle(color: Colors.teal, fontSize: 16),
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    value: selectedTo,
                    items: locations.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTo = value;
                      });
                      filterDrivers();
                    },
                    isExpanded: true, // Full width
                  ),
                ]
              ],
            ),
          ),
          // List of truck drivers
          Expanded(
            child: ListView.builder(
              itemCount: truckDrivers.length,
              itemBuilder: (context, index) {
                final driver = truckDrivers[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  elevation: 5, // Add shadow for depth
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent, // Remove divider lines
                    ),
                    child: ExpansionTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/truck.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                      title: Text(
                        driver['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mashina raqami: ${driver['carNumber']}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qayerdan: ${driver['from']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Text(
                            'Qayerga: ${driver['to']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      childrenPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: [
                        Text(
                          'Telefon raqami: ${driver['phoneNumber']}',
                          style: TextStyle(color: Colors.black),
                        ),
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
}
