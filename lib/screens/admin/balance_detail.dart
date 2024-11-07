import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class BalanceDetailPage extends StatelessWidget {
  final String transactionId;
  const BalanceDetailPage(this.transactionId, {super.key});

  Future<Map<String, dynamic>?> _getDriverData(String userId) async {
    // Запрос к базе данных для получения данных водителя
    final snapshot = await FirebaseFirestore.instance
        .collection('truckdrivers')
        .doc(userId)
        .get();
    return snapshot.exists ? snapshot.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          String userId = transactionData['userId'];

          return FutureBuilder<Map<String, dynamic>?>(
            future: _getDriverData(userId),
            builder: (context, driverSnapshot) {
              if (!driverSnapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var driverData = driverSnapshot.data;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Ism:', driverData?['name'] ?? 'Unknown'),
                    _buildInfoRow(
                        'Familiya:', driverData?['surname'] ?? 'Unknown'),
                    _buildInfoRow(
                        'Telefon:', driverData?['phone_number'] ?? 'N/A'),
                    _buildInfoRow(
                        'Miqdor:', '${transactionData['amount']} UZS'),
                    _buildInfoRow(
                        'Haydovchi id:', '${transactionData['userId']}'),
                    const SizedBox(height: 20),
                    Text('Kvitantsiya:',
                        style: AppStyle.fontStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    const SizedBox(height: 10),
                    _buildReceiptImage(context, transactionData['receiptUrl']),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: _buildConfirmButton(context,
                              driverData?['userId'], transactionData['amount']),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDeleteButton(
                              context, driverData?['userId']),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
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

  Widget _buildConfirmButton(BuildContext context, String? userId, int amount) {
    return ElevatedButton(
      onPressed: () async {
        if (userId != null) {
          await _approveTransaction(userId, amount);
          Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.taxi,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text('Tasdiqlash va balansga qo\'shish',
          style: AppStyle.fontStyle.copyWith(
            fontSize: 16,
            color: Colors.white,
          )),
    );
  }

  Widget _buildDeleteButton(BuildContext context, String? userId) {
    return ElevatedButton(
      onPressed: () async {
        await _deleteTransaction();
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Text('Bekor qilish',
          style: AppStyle.fontStyle.copyWith(
            fontSize: 16,
            color: Colors.white,
          )),
    );
  }

  Future<void> _approveTransaction(String userId, int amount) async {
    QuerySnapshot driverSnapshot = await FirebaseFirestore.instance
        .collection('truckdrivers')
        .where('userId', isEqualTo: userId)
        .get();

    if (driverSnapshot.docs.isNotEmpty) {
      var driverDoc = driverSnapshot.docs.first;
      var driverData = driverDoc.data() as Map<String, dynamic>;
      int currentBalance = driverData['balance'] ?? 0;

      await FirebaseFirestore.instance
          .collection('truckdrivers')
          .doc(driverDoc.id)
          .update({
        'balance': currentBalance + amount,
      });

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionId)
          .update({'status': 'checked'});
    }
  }

  Future<void> _deleteTransaction() async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(transactionId)
        .delete();

    print('Транзакция была удалена');
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
