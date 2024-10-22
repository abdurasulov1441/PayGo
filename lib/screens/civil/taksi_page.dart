import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaxiPage extends StatefulWidget {
  const TaxiPage({super.key});

  @override
  _TaxiPageState createState() => _TaxiPageState();
}

class _TaxiPageState extends State<TaxiPage> {
  String? selectedFrom;
  String? selectedTo;

  List<DocumentSnapshot> taxiDrivers = [];
  List<DocumentSnapshot> allDrivers = []; // Full list of drivers
  List<String> locations = []; // Will be filled with regions from Firestore
  bool isLoadingRegions = true; // To track when regions are being fetched

  Map<String, double> driverRatings = {}; // To store average rating per driver

  @override
  void initState() {
    super.initState();
    fetchRegions(); // Fetch regions from Firestore
    fetchTaxiDrivers(); // Fetch drivers from Firestore
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

  // Fetch taxi drivers
  Future<void> fetchTaxiDrivers() async {
    final drivers = await FirebaseFirestore.instance
        .collection('driver')
        .where('vehicleType', isEqualTo: 'Yengil avtomobil')
        .get();
    setState(() {
      allDrivers = drivers.docs; // Store the full list of drivers
      taxiDrivers = allDrivers; // Show all drivers initially
    });

    // Fetch ratings after fetching the drivers
    fetchDriverRatings();
  }

  // Fetch driver ratings from Firestore
  Future<void> fetchDriverRatings() async {
    final ratingsSnapshot =
        await FirebaseFirestore.instance.collection('driverRatings').get();

    // Calculate the average rating per driver
    Map<String, List<double>> ratingData = {}; // Temporarily store ratings

    for (var doc in ratingsSnapshot.docs) {
      final driverEmail = doc['driverEmail'];
      final rating = doc['rating'].toDouble();

      if (ratingData.containsKey(driverEmail)) {
        ratingData[driverEmail]!.add(rating);
      } else {
        ratingData[driverEmail] = [rating];
      }
    }

    // Calculate the average and store in `driverRatings`
    Map<String, double> calculatedRatings = {};
    ratingData.forEach((driverEmail, ratings) {
      final averageRating =
          ratings.reduce((a, b) => a + b) / ratings.length; // Calculate average
      calculatedRatings[driverEmail] = averageRating;
    });

    setState(() {
      driverRatings = calculatedRatings;
    });
  }

  // Filter the drivers based on selected locations
  void filterDrivers() {
    if (selectedFrom != null && selectedTo != null) {
      setState(() {
        taxiDrivers = allDrivers.where((doc) {
          final from = doc['from'].toLowerCase();
          final to = doc['to'].toLowerCase();

          // Check both directions (Qayerdan-to-Qayerga and Qayerga-to-Qayerdan)
          return (from == selectedFrom!.toLowerCase() &&
                  to == selectedTo!.toLowerCase()) ||
              (from == selectedTo!.toLowerCase() &&
                  to == selectedFrom!.toLowerCase());
        }).toList();
      });
    } else {
      setState(() {
        taxiDrivers = allDrivers; // Reset to show all drivers if no filters
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Taksi Haydovchilari',
          style: TextStyle(color: Colors.white), // Make text white
        ),
        backgroundColor: Colors.teal, // Adjust the background color if needed
        centerTitle: true, // Center the title
        iconTheme: IconThemeData(
          color: Colors.white, // Make the back button icon white
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Show a loading spinner if regions are still being fetched
                if (isLoadingRegions)
                  Center(child: CircularProgressIndicator())
                else ...[
                  // Dropdown for selecting 'Qayerdan' (From location)
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
                  // Dropdown for selecting 'Qayerga' (To location)
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
          Expanded(
            child: ListView.builder(
              itemCount: taxiDrivers.length,
              itemBuilder: (context, index) {
                final driver = taxiDrivers[index];
                final driverEmail =
                    driver['email']; // Driver's email to find rating

                // Get the driver's average rating, or default to "No ratings yet"
                final averageRating = driverRatings.containsKey(driverEmail)
                    ? driverRatings[driverEmail]!.toStringAsFixed(1)
                    : 'No ratings yet';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  elevation: 5,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor:
                          Colors.transparent, // Remove the divider lines
                    ),
                    child: ExpansionTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/car.png',
                          width:
                              80, // Increased the width to make the image more visible
                          height: 80, // Adjust the height as well
                          fit: BoxFit
                              .contain, // Ensures the image is fully visible without cropping
                        ),
                      ),
                      title: Text(driver['name'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mashina raqami: ${driver['carNumber']}'),
                          Text('Qayerdan: ${driver['from']}'),
                          Text('Qayerga: ${driver['to']}'),
                          Text(
                              'Rating: $averageRating'), // Display average rating
                        ],
                      ),
                      childrenPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical:
                              8), // Adjust padding for the expanded content
                      children: [
                        Text('Telefon raqami: ${driver['phoneNumber']}'),
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
