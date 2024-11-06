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
        await FirebaseFirestore.instance.collection('price').get();
    setState(() {
      subscriptionPlans = querySnapshot.docs
          .map((doc) => doc.data())
          .toList();
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
                          price: '${plan['price']} UZS',
                          savings: plan['coment'],
                          cost: plan['price'],
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
    required String savings,
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
                    ? null
                    : () {
                        setState(() {
                          selectedPlan = title;
                          isLoading = true;
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

  Future<void> _confirmSubscription(
      BuildContext context, String plan, int cost) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foydalanuvchi tizimga kirmagan!')),
        );
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('driver')
          .doc(user.uid)
          .get();

      int balance = userDoc['balance'];
      Timestamp? currentExpiration = userDoc['expired_date'];

      if (balance >= cost) {
        DateTime newExpirationDate;

        if (currentExpiration != null &&
            currentExpiration.toDate().isAfter(DateTime.now())) {
          Duration additionalDuration = Duration(
              days: plan == '1 Oylik' ? 31 : (plan == '6 Oylik' ? 186 : 365));
          newExpirationDate =
              currentExpiration.toDate().add(additionalDuration);
        } else {
          newExpirationDate = DateTime.now().add(Duration(
              days: plan == '1 Oylik' ? 31 : (plan == '6 Oylik' ? 186 : 365)));
        }

        await FirebaseFirestore.instance
            .collection('driver')
            .doc(user.uid)
            .update({
          'balance': balance - cost,
          'subscription_plan': plan,
          'expired_date': newExpirationDate,
        });

        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Muvaffaqiyatli obuna bo‘ldingiz!')),
        );
      } else {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Balansingiz yetarli emas!')),
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
