import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? selectedPlan;
  List<Map<String, dynamic>> subscriptionPlans = [];

  @override
  void initState() {
    super.initState();
    fetchSubscriptionPlans();
  }

  Future<void> fetchSubscriptionPlans() async {
    setState(() => isLoading = true);
    final querySnapshot =
        await FirebaseFirestore.instance.collection('data').doc('tarif').get();
    setState(() {
      subscriptionPlans = List<Map<String, dynamic>>.from(
          querySnapshot.data()?['tarifs'] ?? []);
      isLoading = false;
    });
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
                    ...subscriptionPlans.map((plan) => _buildSubscriptionCard(
                          context,
                          title: plan['name'],
                          price: '${plan['sum_cost']} UZS',
                          description: plan['coment'],
                          period: plan['period'],
                          cost: plan['sum_cost'],
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
    required String period,
    required int cost,
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
              SizedBox(height: 10),
              Text(
                'Muddat: $period',
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedPlan = title;
                    isLoading = true;
                  });
                  _confirmSubscription(context, title, cost, period);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                ),
                child: isLoading && selectedPlan == title
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.taxi,
                        ),
                      )
                    : Text(
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

  Future<void> _confirmSubscription(
      BuildContext context, String plan, int cost, String period) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foydalanuvchi tizimga kirmagan!')),
        );
        return;
      }

      // Find the driver by email
      final driverQuery = await FirebaseFirestore.instance
          .collection('truckdrivers')
          .where('email', isEqualTo: user.email)
          .get();

      if (driverQuery.docs.isEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Haydovchi topilmadi!')),
        );
        return;
      }

      final driverDoc = driverQuery.docs.first;
      final driverData = driverDoc.data();

      int balance = driverData['balance'] ?? 0;
      Timestamp? currentExpiration = driverData['expired_date'];
      int daysToAdd = period == '1 oy'
          ? 30
          : period == '6 oy'
              ? 180
              : 365;

      if (balance >= cost) {
        // Calculate the new expiration date
        DateTime newExpirationDate;
        if (currentExpiration != null &&
            currentExpiration.toDate().isAfter(DateTime.now())) {
          newExpirationDate =
              currentExpiration.toDate().add(Duration(days: daysToAdd));
        } else {
          newExpirationDate = DateTime.now().add(Duration(days: daysToAdd));
        }

        // Update balance, subscription plan, and expiration date in Firestore
        await FirebaseFirestore.instance
            .collection('truckdrivers')
            .doc(driverDoc.id)
            .update({
          'balance': balance - cost,
          'subscription_plan': plan,
          'expired_date': newExpirationDate,
        });

        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Muvaffaqiyatli obuna bo‘ldingiz!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Balansingiz yetarli emas!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik yuz berdi: $e')),
      );
    }
  }
}
