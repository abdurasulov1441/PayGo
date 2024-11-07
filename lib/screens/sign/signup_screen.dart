import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taksi/screens/sign/verify_email_screen.dart';
import 'package:taksi/services/snack_bar.dart';
import 'package:taksi/style/app_colors.dart';
import 'package:taksi/style/app_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  bool isHiddenPassword = true;
  TextEditingController emailTextInputController = TextEditingController();
  TextEditingController passwordTextInputController = TextEditingController();
  TextEditingController passwordTextRepeatInputController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailTextInputController.dispose();
    passwordTextInputController.dispose();
    passwordTextRepeatInputController.dispose();
    super.dispose();
  }

  void togglePasswordView() {
    setState(() {
      isHiddenPassword = !isHiddenPassword;
    });
  }

  Future<void> signUp() async {
    final navigator = Navigator.of(context);
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    if (passwordTextInputController.text !=
        passwordTextRepeatInputController.text) {
      SnackBarService.showSnackBar(
          context, 'Parollar bir xil bo‘lishi kerak', true);
      return;
    }

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextInputController.text.trim(),
        password: passwordTextInputController.text.trim(),
      );

      // Navigate to VerifyEmailScreen
      if (mounted) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (context) => VerifyEmailScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Xatolik yuz berdi';
      if (e.code == 'email-already-in-use') {
        message = 'Ushbu email allaqachon mavjud';
      }
      if (mounted) {
        SnackBarService.showSnackBar(context, message, true);
      }
    }
  }

  Future<void> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled the sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase sign-in
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if the user exists in Firestore
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          if (mounted) {
            // If the user already exists, show error dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Xatolik"),
                  content:
                      Text("Bu email bilan foydalanuvchi allaqachon mavjud."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("OK"),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          // If the user doesn't exist, create a new record in Firestore
          final userData = {
            'email': user.email,
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          };

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(userData);

          // Navigate to the email verification screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => VerifyEmailScreen()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kirishda xatolik: ${e.message}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              Text(
                'Ro’yxatdan o’tish',
                style: AppStyle.fontStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 20),
              buildTextField(
                emailTextInputController,
                'Email',
                Icons.mail,
                keyboardType: TextInputType.emailAddress,
                validator: (email) =>
                    email != null && !EmailValidator.validate(email)
                        ? 'To’g’ri email kiriting'
                        : null,
              ),
              const SizedBox(height: 15),
              buildTextField(
                passwordTextInputController,
                'Parol',
                Icons.lock,
                obscureText: isHiddenPassword,
                validator: (value) => value != null && value.length < 6
                    ? 'Kamida 6 ta belgidan iborat bo’lishi kerak'
                    : null,
              ),
              const SizedBox(height: 15),
              buildTextField(
                passwordTextRepeatInputController,
                'Parolni qayta kiriting',
                Icons.lock,
                obscureText: isHiddenPassword,
                validator: (value) =>
                    value != null && value != passwordTextInputController.text
                        ? 'Parollar mos kelishi kerak'
                        : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.taxi,
                  minimumSize: Size(double.infinity, 50), // full width button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: signUp,
                child: Text('Ro’yxatdan o’tish',
                    style: AppStyle.fontStyle.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize:
                      const Size(double.infinity, 50), // full width button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: googleSignIn,
                icon: Image.asset(
                  'assets/images/google.jpg',
                  height: 24,
                  width: 24,
                ),
                label: Text(
                  'Google orqali kirish',
                  style: AppStyle.fontStyle.copyWith(color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Akkauntingiz bormi?'),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Kirish',
                        style:
                            AppStyle.fontStyle.copyWith(color: AppColors.taxi),
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      style: AppStyle.fontStyle.copyWith(color: AppColors.textColor),
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator ??
          (value) =>
              value == null || value.isEmpty ? 'Bu maydonni to’ldiring' : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(icon, color: AppColors.taxi),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: AppStyle.fontStyle.copyWith(color: Colors.grey),
      ),
    );
  }
}
