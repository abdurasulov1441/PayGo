import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TruckOrderHistoryPage extends StatefulWidget {
  const TruckOrderHistoryPage({super.key});

  @override
  _TruckOrderHistoryPageState createState() => _TruckOrderHistoryPageState();
}

class _TruckOrderHistoryPageState extends State<TruckOrderHistoryPage> {
  Map<String, double> orderRatings = {};
  Map<String, String> ratingDocIds = {};
  Map<String, bool> expandedStates = {};

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentUserEmail != null) {
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('driverTruckRatings')
          .where('ratedBy', isEqualTo: currentUserEmail)
          .get();
      setState(() {
        for (var doc in ratingsSnapshot.docs) {
          orderRatings[doc['order_id']] = doc['rating'].toDouble();
          ratingDocIds[doc['order_id']] = doc.id;
        }
      });
    }
  }

  void _callDriver(String phoneNumber) async {
    String sanitizedPhoneNumber =
        phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final intent = AndroidIntent(
      action: 'android.intent.action.CALL',
      data: 'tel:$sanitizedPhoneNumber',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    try {
      await intent.launch();
    } catch (e) {
      _showSnackBar(
          "Qo'ng'iroq amalga oshmadi. Telefon sozlamalarini tekshiring.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.taxi,
        title: Text(
          'Yuk buyurtmalari tarixi',
          style: AppStyle.fontStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('truck_orders')
            .where('user_id',
                isEqualTo: '000001') // Замените на ID пользователя
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Buyurtmalar mavjud emas'));
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((doc) {
              return _buildTruckOrderCard(doc);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildTruckOrderCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String orderNumber = doc.id;
    String fromLocation = data['from'] ?? 'Noma\'lum';
    String toLocation = data['to'] ?? 'Noma\'lum';
    double cargoWeight = (data['cargo_weight'] as num?)?.toDouble() ?? 0.0;
    String cargoName = data['cargo_name'] ?? 'Yuk nomi mavjud emas';
    String orderStatus = data['status'] ?? 'Status mavjud emas';
    DateTime acceptTime = (data['accept_time'] as Timestamp).toDate();
    DateTime chosenTime = (data['chosen_time'] as Timestamp).toDate();
    String driverUserId = data['driver_user_id'] ?? 'ID mavjud emas';
    String driverName = data['driver_name'] ?? 'Ism mavjud emas';
    String driverPhoneNumber =
        data['driver_phone_number'] ?? 'Telefon raqami mavjud emas';
    String driverTruckModel =
        data['driver_truck_model'] ?? 'Mashina mavjud emas';
    String driverTruckNumber =
        data['driver_truck_number'] ?? 'Avtomobil raqami mavjud emas';

    bool isExpanded = expandedStates[doc.id] ?? false;

    Color getStatusColor(String status) {
      if (status == 'qabul qilindi') {
        return Colors.orange;
      } else if (status == 'tamomlandi') {
        return Colors.green;
      } else {
        return Colors.red;
      }
    }

    return GestureDetector(
      onTap: () {
        if (orderStatus == 'qabul qilindi') {
          setState(() {
            expandedStates[doc.id] = !isExpanded;
          });
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildOrderNumberTag(orderNumber),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(acceptTime),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: getStatusColor(orderStatus),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        orderStatus,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            _buildLocationRow(fromLocation, toLocation, acceptTime, chosenTime),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yuk nomi: $cargoName',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Yuk vazni: ${cargoWeight.toStringAsFixed(2)} kg',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Haydovchi ID: $driverUserId',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                if (orderStatus == 'qabul qilindi')
                  ElevatedButton(
                    onPressed: () {
                      _showBanDialog(doc);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.taxi,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Shikoyat",
                      style: AppStyle.fontStyle.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),
            if (orderStatus == 'tamomlandi')
              _buildRatingBar(
                  doc.id, driverUserId, driverName, driverPhoneNumber),
            if (orderStatus == 'qabul qilindi' && isExpanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Text(
                    'Haydovchi: $driverName',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.green),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _callDriver(driverPhoneNumber),
                        child: Text(
                          'Telefon raqami: $driverPhoneNumber',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text('Mashina modeli: $driverTruckModel',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  SizedBox(height: 4),
                  Text('Mashina raqami: $driverTruckNumber',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNumberTag(String orderNumber) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Buyurtma №$orderNumber',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLocationRow(String fromLocation, String toLocation,
      DateTime acceptTime, DateTime chosenTime) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Qayerdan:',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(fromLocation,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_formatDate(acceptTime),
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        Icon(Icons.arrow_forward, color: Colors.blue),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Qayerga:',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(toLocation,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_formatDate(chosenTime),
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(String orderId, String driverUserId, String driverName,
      String driverPhoneNumber) {
    double initialRating = orderRatings[orderId] ?? 0.0;

    return RatingBar.builder(
      initialRating: initialRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
      onRatingUpdate: (rating) {
        setState(() {
          orderRatings[orderId] = rating;
        });
        _saveOrUpdateRating(
            orderId, rating, driverUserId, driverName, driverPhoneNumber);
      },
    );
  }

  Future<void> _saveOrUpdateRating(String orderId, double rating,
      String driverUserId, String driverName, String driverPhoneNumber) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId != null) {
      if (rating <= 1.0) {
        await _showComplaintDialog(orderId, driverUserId, currentUserId,
            driverName, driverPhoneNumber);
      } else {
        if (ratingDocIds.containsKey(orderId)) {
          await FirebaseFirestore.instance
              .collection('driverTruckRatings')
              .doc(ratingDocIds[orderId])
              .update({'rating': rating});
        } else {
          DocumentReference docRef = await FirebaseFirestore.instance
              .collection('driverTruckRatings')
              .add({
            'order_id': orderId,
            'rating': rating,
            'ratedBy': currentUserId,
          });
          setState(() {
            ratingDocIds[orderId] = docRef.id;
          });
        }
      }
    }
  }

  Future<void> _showComplaintDialog(String orderId, String driverUserId,
      String userEmail, String driverName, String driverPhoneNumber) async {
    TextEditingController complaintController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.taxi,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.feedback, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Izohingizni yuboring',
                      style: AppStyle.fontStyle.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haydovchi bilan bog‘liq muammoingizni tushuntiring:',
                      style: AppStyle.fontStyle.copyWith(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: complaintController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Muammoni shu yerda tushuntiring",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Bekor qilish",
                        style: AppStyle.fontStyle.copyWith(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final complaintText = complaintController.text;
                        if (complaintText.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('feedback')
                              .add({
                            'orderId': orderId,
                            'driverUserId': driverUserId,
                            'userEmail': userEmail,
                            'driverName': driverName,
                            'driverPhoneNumber': driverPhoneNumber,
                            'complaint': complaintText,
                            'timestamp': DateTime.now(),
                          });
                          Navigator.of(context).pop();
                          _showSnackBar('Fikr muvaffaqiyatli yuborildi');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.taxi,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Yuborish",
                        style: AppStyle.fontStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showBanDialog(DocumentSnapshot orderDoc) async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentUserEmail == null) {
      _showSnackBar("Xatolik: Foydalanuvchi tizimga kirmagan.");
      return;
    }

    // Buyurtma tafsilotlari
    String driverUserId = orderDoc['accepted_by'] ?? '';
    String passengerEmail = currentUserEmail;

    if (driverUserId.isEmpty) {
      _showSnackBar("Xatolik: Haydovchi ID topilmadi.");
      return;
    }

    try {
      // Yo'lovchi ID sini email orqali olish
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: passengerEmail)
          .get();

      if (userSnapshot.docs.isEmpty) {
        _showSnackBar('Foydalanuvchi topilmadi.');
        return;
      }

      String passengerId = userSnapshot.docs.first.id;

      // Banlisttruck kolleksiyasida haydovchi va yo'lovchi IDlarini tekshirish
      final driverBanDocRef = FirebaseFirestore.instance
          .collection('banlisttruck')
          .doc(driverUserId);

      QuerySnapshot existingComplaintSnapshot = await driverBanDocRef
          .collection('complaints')
          .where('passengerId', isEqualTo: passengerId)
          .get();

      if (existingComplaintSnapshot.docs.isNotEmpty) {
        _showSnackBar('Siz ushbu haydovchiga allaqachon shikoyat qildingiz.');
        return;
      }

      // Haydovchi ma'lumotlarini olish
      DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
          .collection('truckdrivers')
          .doc(driverUserId)
          .get();

      String driverName = driverSnapshot['name'] ?? 'Noma\'lum';
      String driverPhoneNumber = driverSnapshot['phone_number'] ?? 'Noma\'lum';

      // Tasdiqlash dialogini ko'rsatish
      bool confirm = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Shikoyat qilish"),
            content: Text(
                "Haqiqatan ham ushbu haydovchiga shikoyat qilmoqchimisiz?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Yo'q", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.taxi,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Ha",
                  style: AppStyle.fontStyle.copyWith(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );

      if (!confirm) return;

      // Yangi shikoyatni complaints kolleksiyasiga qo'shish
      await driverBanDocRef.collection('complaints').add({
        'driverUserId': driverUserId,
        'driverName': driverName,
        'driverPhoneNumber': driverPhoneNumber,
        'passengerId': passengerId,
        'complaint': "Past reyting yoki boshqa sabab tufayli shikoyat qilindi",
        'timestamp': DateTime.now(),
      });

      // Ushbu haydovchiga qarshi shikoyatlar sonini hisoblash
      QuerySnapshot complaintsSnapshot =
          await driverBanDocRef.collection('complaints').get();

      int complaintCount = complaintsSnapshot.docs.length;

      // Agar shikoyatlar soni 3 yoki undan ko'p bo'lsa, haydovchini bloklash
      if (complaintCount >= 3) {
        await FirebaseFirestore.instance
            .collection('truckdrivers')
            .doc(driverUserId)
            .update({'status': 'inactive'});
        _showSnackBar('Haydovchi ko‘p shikoyatlar tufayli bloklandi.');
      } else {
        _showSnackBar('Shikoyat muvaffaqiyatli ro‘yxatga olindi');
      }
    } catch (e) {
      print('Xatolik saqlashda: ${e.toString()}');
      _showSnackBar('Xatolik: Shikoyatni ro\'yxatga olish imkoni yo\'q');
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }
}
