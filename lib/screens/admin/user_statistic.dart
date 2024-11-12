import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class UserDriverStatisticsPage extends StatefulWidget {
  const UserDriverStatisticsPage({super.key});

  @override
  _UserDriverStatisticsPageState createState() =>
      _UserDriverStatisticsPageState();
}

class _UserDriverStatisticsPageState extends State<UserDriverStatisticsPage> {
  final TextEditingController _searchController = TextEditingController();
  int totalPassengers = 0;
  int totalDrivers = 0;
  String? _selectedRole;
  String? _searchUserId;

  @override
  void initState() {
    super.initState();
    fetchUserStatistics();
  }

  Future<void> fetchUserStatistics() async {
    QuerySnapshot passengerSnapshot =
        await FirebaseFirestore.instance.collection('user').get();
    QuerySnapshot driverSnapshot =
        await FirebaseFirestore.instance.collection('truckdrivers').get();

    setState(() {
      totalPassengers = passengerSnapshot.size;
      totalDrivers = driverSnapshot.size;
    });
  }

  void _startSearch(String role) {
    setState(() {
      _selectedRole = role;
      _searchUserId = null;
    });
  }

  void _searchById(String userId) {
    setState(() {
      _searchUserId = userId;
    });
  }

  Future<void> _toggleStatus(
      String id, String collection, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'inactive' : 'active';
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(id)
        .update({'status': newStatus});

    setState(() {
      // Trigger rebuild to reflect the new status
      _searchUserId = id; // Ensures the card reloads with the updated status
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics summary section with tappable cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _startSearch('passenger'),
                  child: _buildStatisticCard(
                      'Jami Yo\'lovchilar', totalPassengers, Colors.blueAccent),
                ),
                GestureDetector(
                  onTap: () => _startSearch('driver'),
                  child: _buildStatisticCard(
                      'Jami Haydovchilar', totalDrivers, Colors.green),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Conditional Search Bar based on selected role
            if (_selectedRole != null)
              Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          'ID bo\'yicha qidirish (${_selectedRole == 'passenger' ? 'Yo\'lovchi' : 'Haydovchi'})',
                      prefixIcon: Icon(Icons.search, color: AppColors.taxi),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.taxi),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.taxi),
                      ),
                    ),
                    onSubmitted: _searchById,
                  ),
                  SizedBox(height: 20),
                ],
              ),

            // Results section
            Expanded(
              child: _searchUserId != null && _selectedRole != null
                  ? _buildSearchResults()
                  : Center(
                      child: Text(
                        'Foydalanuvchi yoki haydovchini tanlang yoki qidirish qiling.',
                        style: AppStyle.fontStyle,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Build search results based on the selected role and input ID
  Widget _buildSearchResults() {
    if (_searchUserId == null || _searchUserId!.isEmpty) {
      return Center(
        child: Text(
          '${_selectedRole == 'passenger' ? 'Yo\'lovchi' : 'Haydovchi'} IDni kiriting.',
          style: AppStyle.fontStyle,
        ),
      );
    }

    final collection = _selectedRole == 'passenger' ? 'user' : 'truckdrivers';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .doc(_searchUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.data != null && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          return _buildUserCard(
            id: snapshot.data!.id,
            name: userData['name'],
            surname: userData['surname'],
            phoneNumber: userData['phone_number'],
            email: userData['email'],
            role: _selectedRole == 'passenger' ? 'Yo\'lovchi' : 'Haydovchi',
            status: userData['status'], // Include the status
            collection: collection, // Pass the collection for updating
            truckModel:
                _selectedRole == 'driver' ? userData['truck_model'] : null,
            truckNumber:
                _selectedRole == 'driver' ? userData['truck_number'] : null,
          );
        } else {
          return Center(
            child: Text(
              '${_selectedRole == 'passenger' ? 'Yo\'lovchi' : 'Haydovchi'} topilmadi.',
              style: AppStyle.fontStyle,
            ),
          );
        }
      },
    );
  }

  // Statistic card widget
  Widget _buildStatisticCard(String title, int count, Color color) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: AppStyle.fontStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: AppStyle.fontStyle.copyWith(
              fontSize: 16,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String id,
    required String name,
    required String surname,
    required String phoneNumber,
    required String email,
    required String role,
    required String status,
    required String collection,
    String? truckModel,
    String? truckNumber,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$role ID: $id',
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.taxi,
                  ),
                ),
                Text(
                  'Status: $status',
                  style: AppStyle.fontStyle.copyWith(
                    fontSize: 14,
                    color: status == 'active' ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (role == 'Haydovchi' &&
                truckModel != null &&
                truckNumber != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Text(
                      'Model: $truckModel',
                      style: AppStyle.fontStyle.copyWith(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Raqam: $truckNumber',
                      style: AppStyle.fontStyle.copyWith(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            Divider(color: Colors.grey[300], thickness: 1, height: 20),
            SizedBox(height: 8),
            Text(
              'Ism: $name',
              style: AppStyle.fontStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Familiya: $surname',
              style: AppStyle.fontStyle.copyWith(
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Aloqa: $phoneNumber',
              style: AppStyle.fontStyle.copyWith(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            if (email.isNotEmpty)
              Text(
                'Email: $email',
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _toggleStatus(id, collection, status),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      status == 'active' ? Colors.red : Colors.green,
                ),
                child: Text(
                  status == 'active' ? 'Bloklash' : 'Blokdan yechish',
                  style: AppStyle.fontStyle.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
