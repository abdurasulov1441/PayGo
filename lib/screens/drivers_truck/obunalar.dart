import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class ObunalarPage extends StatefulWidget {
  const ObunalarPage({super.key});

  @override
  _ObunalarPageState createState() => _ObunalarPageState();
}

class _ObunalarPageState extends State<ObunalarPage> {
  bool isLoading = false;
  List<Map<String, dynamic>> subscriptionPlans = [];

  @override
  void initState() {
    super.initState();
    fetchSubscriptionPlans();
  }

  Future<void> fetchSubscriptionPlans() async {
    setState(() => isLoading = true);
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('tarif').get();

      if (querySnapshot.docs.isEmpty) {
        print("No subscription plans found in 'tarif' collection.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tariflar topilmadi!')),
        );
      } else {
        print("Fetched subscription plans:");
        querySnapshot.docs.forEach((doc) {
          print(doc.data()); // Debug print for each document
        });
        setState(() {
          subscriptionPlans = querySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      print("Error fetching subscription plans: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik yuz berdi: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        centerTitle: true,
        title: Text(
          'Obunalar',
          style: AppStyle.fontStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : subscriptionPlans.isEmpty
                ? Center(child: Text('Tariflar mavjud emas.'))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Tanlang Obunani:',
                          style: AppStyle.fontStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.taxi,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ...subscriptionPlans
                            .map((plan) => _buildSubscriptionCard(
                                  context,
                                  title: plan['name'] ?? 'Noma\'lum tarif',
                                  price: '${plan['price'] ?? '0'} UZS',
                                  description:
                                      plan['coment'] ?? 'Izoh mavjud emas',
                                )),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context, {
    required String title,
    required String price,
    required String description,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: AppColors.taxi,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: AppStyle.fontStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                price,
                style: AppStyle.fontStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                description,
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() => isLoading = true);
                  // Call to subscription confirmation function
                  _confirmSubscription(context, title);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                ),
                child: Text(
                  'TANLASH',
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.taxi,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSubscription(BuildContext context, String plan) async {
    // Logic to confirm subscription with proper error handling
  }
}
