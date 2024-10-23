import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class DetailPage extends StatelessWidget {
  final String driverId;

  const DetailPage(this.driverId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text('Haydovchi ma\'lumotlari',
            style: AppStyle.fontStyle.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.taxi,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('driver').doc(driverId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var driverData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(driverData), // Карточка с информацией о водителе
                const SizedBox(height: 20),
                Divider(color: Colors.grey[400], thickness: 1),
                const SizedBox(height: 10),
                _buildImageSection(driverData, context), // Секция с картинками
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('driver')
                          .doc(driverId)
                          .update({'status': 'active'});

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.taxi,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Tekshirishni tasdiqlash',
                        style: AppStyle.fontStyle.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Функция для создания карточки с информацией о водителе
  // Функция для создания карточки с информацией о водителе
  Widget _buildInfoCard(Map<String, dynamic> driverData) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextRow('Ism', driverData['name']),
              _buildTextRow('Familiya', driverData['lastName']),
              _buildTextRow('Telefon', driverData['phoneNumber']),
              _buildTextRow('Mashina turi', driverData['vehicleType']),
              _buildTextRow(
                  'Mashina markasi', driverData['carModel']), // Марка машины
              _buildTextRow(
                  'Mashina raqami', driverData['carNumber']), // Номер машины
              _buildTextRow('Qayerdan', driverData['from']),
              _buildTextRow('Qayerga', driverData['to']),
            ],
          ),
        ),
      ),
    );
  }

  // Хелпер для создания строки текста с жирным заголовком
  Widget _buildTextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: AppStyle.fontStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          children: <TextSpan>[
            TextSpan(
              text: value,
              style: AppStyle.fontStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Секция с картинками
  Widget _buildImageSection(
      Map<String, dynamic> driverData, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageTile('Mashina old tomoni', driverData['frontCar'], context),
        _buildImageTile('Mashina yon tomoni', driverData['sideCar'], context),
        _buildImageTile('Mashina orqa tomoni', driverData['backCar'], context),
        _buildImageTile('Haydovchilik guvohnomasi oldi',
            driverData['frontLicense'], context),
        _buildImageTile('Haydovchilik guvohnomasi orqasi',
            driverData['backLicense'], context),
        _buildImageTile('Pasport oldi', driverData['frontPassport'], context),
        _buildImageTile('Pasport orqasi', driverData['backPassport'], context),
      ],
    );
  }

  // Функция для отображения изображения с возможностью просмотра в полном экране
  Widget _buildImageTile(String label, String? imageUrl, BuildContext context) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Column(
        children: [
          Text('$label:'),
          const SizedBox(height: 5),
          Text('Rasm yuklanmagan',
              style: AppStyle.fontStyle.copyWith(color: Colors.red)),
          const SizedBox(height: 10),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: AppStyle.fontStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () {
            // Навигация на полноэкранный просмотр изображения
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImagePage(imageUrl: imageUrl),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Полноэкранный просмотр изображения
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
