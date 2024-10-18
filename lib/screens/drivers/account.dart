import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taksi/screens/civil/civil_page.dart';

class AkkauntPage extends StatelessWidget {
  const AkkauntPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainCivilPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: Chiqishda xatolik yuz berdi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Akkaunt',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            label: const Text('Chiqish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
