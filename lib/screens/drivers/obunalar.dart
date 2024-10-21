import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taksi/style/app_colors.dart'; // Import your custom colors
import 'package:taksi/style/app_style.dart'; // Import your custom styles

class ObunalarPage extends StatefulWidget {
  const ObunalarPage({super.key});

  @override
  _ObunalarPageState createState() => _ObunalarPageState();
}

class _ObunalarPageState extends State<ObunalarPage> {
  bool isLoading = false; // To track loading status
  String? selectedPlan; // To track which plan is selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        centerTitle: true,
        title: Text(
          'Obunalar',
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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

              // 1 Month Subscription (No savings)
              _buildSubscriptionCard(
                context,
                title: '1 Oylik',
                price: '30 000 UZS',
                savings: 'Tejash yo‘q',
                cost: 30000,
              ),

              // 6 Month Subscription (Savings)
              _buildSubscriptionCard(
                context,
                title: '6 Oylik',
                price: '160 000 UZS',
                savings: '20 000 UZS tejang',
                cost: 160000,
              ),

              // 12 Month Subscription (Savings)
              _buildSubscriptionCard(
                context,
                title: '1 Yillik',
                price: '300 000 UZS',
                savings: '60 000 UZS tejang',
                cost: 300000,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a card widget for each subscription option
  Widget _buildSubscriptionCard(
    BuildContext context, {
    required String title,
    required String price,
    required String savings,
    required int cost, // Cost of the subscription
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: MediaQuery.of(context).size.width *
            0.9, // Make card width responsive
        decoration: BoxDecoration(
          color: AppColors.taxi, // Uniform taxi color
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
                savings,
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading
                    ? null // Disable button while loading
                    : () {
                        setState(() {
                          selectedPlan = title; // Set selected plan
                          isLoading = true; // Start loading
                        });
                        _confirmSubscription(context, title, cost);
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

  // Confirm subscription by checking balance, checking previous subscription, and updating Firestore
  Future<void> _confirmSubscription(
      BuildContext context, String plan, int cost) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false; // Stop loading
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foydalanuvchi tizimga kirmagan!')),
        );
        return;
      }

      // Fetch user balance and subscription data
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('driver')
          .doc(user.uid)
          .get();

      int balance = userDoc['balance'];
      Timestamp? currentExpiration = userDoc['expired_date'];

      if (balance >= cost) {
        DateTime newExpirationDate;

        // Check if there's an existing subscription with time left
        if (currentExpiration != null &&
            currentExpiration.toDate().isAfter(DateTime.now())) {
          // Add the new subscription to the remaining time
          Duration additionalDuration = Duration(
              days: plan == '1 Oylik' ? 31 : (plan == '6 Oylik' ? 186 : 365));
          newExpirationDate =
              currentExpiration.toDate().add(additionalDuration);
        } else {
          // Start a fresh subscription from the current date
          newExpirationDate = DateTime.now().add(Duration(
              days: plan == '1 Oylik' ? 31 : (plan == '6 Oylik' ? 186 : 365)));
        }

        // Deduct balance and update subscription info
        await FirebaseFirestore.instance
            .collection('driver')
            .doc(user.uid)
            .update({
          'balance': balance - cost,
          'subscription_plan': plan,
          'expired_date': newExpirationDate,
        });

        setState(() {
          isLoading = false; // Stop loading
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Muvaffaqiyatli obuna bo‘ldingiz!')),
        );
      } else {
        setState(() {
          isLoading = false; // Stop loading
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Balansingiz yetarli emas!')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik yuz berdi: $e')),
      );
    }
  }
}
