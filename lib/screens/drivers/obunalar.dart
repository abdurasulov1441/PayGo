import 'package:flutter/material.dart';
import 'package:taksi/style/app_colors.dart'; // Import your custom colors
import 'package:taksi/style/app_style.dart'; // Import your custom styles

class ObunalarPage extends StatelessWidget {
  const ObunalarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Obunalar',
          style: AppStyle.fontStyle.copyWith(color: Colors.white),
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
                'Obunani Tanlang:',
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
                onTap: () {
                  _subscribe(context, '1 Oylik', 30000);
                },
                featureList: [
                  'Oddiy dizayn',
                  'Cheklangan buyurtmalar',
                  'Bildirishnoma funksiyasi yo‘q'
                ],
              ),

              // 6 Month Subscription (Savings)
              _buildSubscriptionCard(
                context,
                title: '6 Oylik',
                price: '160 000 UZS',
                savings: '20 000 UZS tejang',
                onTap: () {
                  _subscribe(context, '6 Oylik', 160000);
                },
                featureList: [
                  'Zamonaviy dizayn',
                  'Cheklangan buyurtmalar',
                  'Bildirishnoma orqali buyurtmalarni qabul qilish'
                ],
              ),

              // 12 Month Subscription (Savings)
              _buildSubscriptionCard(
                context,
                title: '1 Yillik',
                price: '300 000 UZS',
                savings: '60 000 UZS tejang',
                onTap: () {
                  _subscribe(context, '1 Yillik', 300000);
                },
                featureList: [
                  'Eng chiroyli dizayn',
                  'Barcha hududlardan cheklanmagan buyurtmalar',
                  'Bildirishnoma orqali buyurtmalarni qabul qilish',
                  'Qo‘shimcha funksiyalar'
                ],
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
    required VoidCallback onTap,
    required List<String> featureList,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: featureList.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: AppStyle.fontStyle.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            softWrap: true,
                            maxLines:
                                2, // Limit the number of lines to prevent overflow
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onTap,
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

  // Simulate the subscription action (later you can integrate actual payment logic)
  void _subscribe(BuildContext context, String plan, int price) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Siz $plan uchun $price UZS to‘lashni tanladingiz.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
