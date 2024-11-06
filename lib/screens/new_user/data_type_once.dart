// import 'package:cloud_firestore/cloud_firestore.dart';

// void createDataCollection() async {
//   // Создаем коллекцию 'data' и документ 'regions' с перечислением регионов
//   await FirebaseFirestore.instance.collection('data').doc('regions').set({
//     'regions': [
//       'Toshkent sh',
//       'Toshkent v',
//       'Sirdaryo',
//       'Jizzax',
//       'Samarqand',
//       'Farg\'ona',
//       'Namangan',
//       'Andijon',
//       'Qashqadaryo',
//       'Surxondaryo',
//       'Buxoro',
//       'Navoiy',
//       'Xorazm',
//       'Qoraqalpog\'iston R'
//     ],
//   });

//   // Создаем документ 'tarif' с тремя тарифами
//   await FirebaseFirestore.instance.collection('data').doc('tarif').set({
//     'tarifs': [
//       {
//         'name': 'Silver',
//         'period': '1 месяц',
//         'sum_cost': 100000,
//         'coment': 'Базовый тариф на месяц'
//       },
//       {
//         'name': 'Gold',
//         'period': '6 месяцев',
//         'sum_cost': 500000,
//         'coment': 'Средний тариф на полгода'
//       },
//       {
//         'name': 'Platinum',
//         'period': '12 месяцев',
//         'sum_cost': 900000,
//         'coment': 'Премиум тариф на год'
//       }
//     ],
//   });

//   // Создаем документ 'card' с данными карты
//   await FirebaseFirestore.instance.collection('data').doc('card').set({
//     'card_number': '8600 1234 5678 9101',
//     'card_holder': 'Ism Familiya',
//   });

//   // Создаем документ 'call_center' с контактной информацией
//   await FirebaseFirestore.instance.collection('data').doc('call_center').set({
//     'name': 'Контактный Центр',
//     'phone_number': '+998 (90) 123 45 67',
//   });
// }
