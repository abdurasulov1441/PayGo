import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class HistoryPaymentPage extends StatefulWidget {
  const HistoryPaymentPage({super.key});

  @override
  _HistoryPaymentPageState createState() => _HistoryPaymentPageState();
}

class _HistoryPaymentPageState extends State<HistoryPaymentPage> {
  int totalIncome = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotalIncome();
  }

  // Метод для подсчета общего дохода от всех "checked" транзакций
  Future<void> _calculateTotalIncome() async {
    QuerySnapshot checkedTransactions = await FirebaseFirestore.instance
        .collection('transactions')
        .where('status', isEqualTo: 'checked')
        .get();

    int income = checkedTransactions.docs.fold(0, (sum, doc) {
      return sum + (doc['amount'] as int);
    });

    setState(() {
      totalIncome = income;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'To\'lovlar tarixi',
          style: AppStyle.fontStyle.copyWith(fontSize: 24),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статистика дохода
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading:
                    Icon(Icons.monetization_on, color: Colors.green, size: 36),
                title: Text(
                  'Umumiy daromad:',
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '$totalIncome UZS',
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Список транзакций
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
                    .where('status', isEqualTo: 'checked')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var transactions = snapshot.data!.docs;

                  if (transactions.isEmpty) {
                    return Center(
                      child: Text(
                        'Cheked to\'lovlar topilmadi.',
                        style: AppStyle.fontStyle,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      var transaction = transactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Метод для создания карточки транзакции с данными пользователя
  Widget _buildTransactionCard(DocumentSnapshot transaction) {
    String userId = transaction['userId'];
    int amount = transaction['amount'];
    String email = transaction['email'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 3,
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('truckdrivers')
            .doc(userId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return ListTile(
              title: Text('Loading user data...'),
              subtitle: Text('$amount UZS'),
            );
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          return ListTile(
            leading:
                Icon(Icons.account_circle, color: AppColors.taxi, size: 40),
            title: Text(
              '${userData?['name'] ?? 'Noma\'lum'} ${userData?['surname'] ?? ''}',
              style: AppStyle.fontStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Miqdor: $amount UZS'),
                Text('Email: $email'),
                Text('Telefon: ${userData?['phone_number'] ?? 'N/A'}'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
          );
        },
      ),
    );
  }
}
