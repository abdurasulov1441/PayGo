import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';

class TarifEditPage extends StatefulWidget {
  const TarifEditPage({super.key});

  @override
  _TarifEditPageState createState() => _TarifEditPageState();
}

class _TarifEditPageState extends State<TarifEditPage> {
  List<Map<String, dynamic>> tarifs = [];

  @override
  void initState() {
    super.initState();
    _loadTarifs();
  }

  Future<void> _loadTarifs() async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance.collection('data').doc('tarif').get();

    if (doc.exists && doc.data() != null) {
      setState(() {
        tarifs = List<Map<String, dynamic>>.from(doc.data()!['tarifs'] ?? []);
      });
    }
  }

  Future<void> _updateTarif(
      int index, Map<String, dynamic> newTarifData) async {
    tarifs[index] = newTarifData;
    await FirebaseFirestore.instance.collection('data').doc('tarif').update({
      'tarifs': tarifs,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Тариф обновлен')),
    );
  }

  void _editTarifDialog(int index, Map<String, dynamic> tarif) {
    TextEditingController nameController =
        TextEditingController(text: tarif['name']);
    TextEditingController commentController =
        TextEditingController(text: tarif['coment']);
    TextEditingController periodController =
        TextEditingController(text: tarif['period']);
    TextEditingController costController =
        TextEditingController(text: tarif['sum_cost'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Редактировать тариф'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Название'),
              ),
              TextField(
                controller: commentController,
                decoration: InputDecoration(labelText: 'Комментарий'),
              ),
              TextField(
                controller: periodController,
                decoration: InputDecoration(labelText: 'Период'),
              ),
              TextField(
                controller: costController,
                decoration: InputDecoration(labelText: 'Стоимость'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateTarif(index, {
                  'name': nameController.text,
                  'coment': commentController.text,
                  'period': periodController.text,
                  'sum_cost': int.parse(costController.text),
                });
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Редактирование тарифов',
          style: AppStyle.fontStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.taxi,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: tarifs.length,
          itemBuilder: (context, index) {
            var tarif = tarifs[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(
                  tarif['name'],
                  style: AppStyle.fontStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Комментарий: ${tarif['coment']}'),
                    Text('Период: ${tarif['period']}'),
                    Text('Стоимость: ${tarif['sum_cost']} UZS'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: AppColors.taxi),
                  onPressed: () => _editTarifDialog(index, tarif),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
