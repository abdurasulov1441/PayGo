import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class BalanceDetailPage extends StatelessWidget {
  final String transactionId;
  const BalanceDetailPage(this.transactionId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('So\'rov detali',
            style: AppStyle.fontStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        backgroundColor: AppColors.taxi,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('transactions')
            .doc(transactionId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var transactionData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Ism:', transactionData['firstName']),
                _buildInfoRow('Familiya:', transactionData['lastName']),
                _buildInfoRow('Telefon:', transactionData['phoneNumber']),
                _buildInfoRow('Miqdor:', '${transactionData['amount']} UZS'),
                const SizedBox(height: 20),
                Text('Kvitantsiya:',
                    style: AppStyle.fontStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    )),
                const SizedBox(height: 10),
                _buildReceiptImage(context, transactionData['receiptUrl']),
                const SizedBox(height: 30),
                _buildConfirmButton(context, transactionData['email'],
                    transactionData['amount']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ',
              style: AppStyle.fontStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.taxi,
              )),
          Expanded(child: Text(value, style: AppStyle.fontStyle)),
        ],
      ),
    );
  }

  Widget _buildReceiptImage(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImagePage(imageUrl),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          imageUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, String email, int amount) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await _approveTransaction(email, amount);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.taxi, // Основной цвет кнопки
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text('Tasdiqlash va balansga qo\'shish',
            style: AppStyle.fontStyle.copyWith(
              fontSize: 16,
              color: Colors.white,
            )),
      ),
    );
  }

  Future<void> _approveTransaction(String email, int amount) async {
    // Получаем документ водителя по email
    QuerySnapshot driverSnapshot = await FirebaseFirestore.instance
        .collection('driver')
        .where('email', isEqualTo: email)
        .get();

    if (driverSnapshot.docs.isNotEmpty) {
      var driverDoc = driverSnapshot.docs.first;
      var driverData = driverDoc.data() as Map<String, dynamic>;
      int currentBalance = driverData['balance'] ?? 0;

      // Обновляем баланс водителя
      await FirebaseFirestore.instance
          .collection('driver')
          .doc(driverDoc.id)
          .update({
        'balance': currentBalance + amount,
      });

      // Обновляем статус транзакции на 'checked'
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .update({'status': 'checked'});
    }
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
