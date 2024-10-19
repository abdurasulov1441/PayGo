// import 'package:cloud_firestore/cloud_firestore.dart';

// Future<void> addRegionsToFirestore() async {
//   // Данные регионов
//   List<Map<String, String>> regions = [
//     {'region': 'Qoraqalpog\'iston R'},
//     {'region': 'Andijon'},
//     {'region': 'Buxoro'},
//     {'region': 'Jizzax'},
//     {'region': 'Qashqadaryo'},
//     {'region': 'Namangan'},
//     {'region': 'Navoiy'},
//     {'region': 'Samarqand'},
//     {'region': 'Surxondaryo'},
//     {'region': 'Sirdaryo'},
//     {'region': 'Toshkent sh'},
//     {'region': 'Toshkent v'},
//     {'region': 'Farg\'ona'},
//     {'region': 'Xorazm'},
//   ];

//   // Цикл для добавления каждого региона в базу данных
//   for (var regionData in regions) {
//     // Добавление в коллекцию "regions"
//     await FirebaseFirestore.instance.collection('regions').add(regionData);
//   }

//   print('Regions added successfully!');
// }
