import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  String message = '';

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      setState(() {
        message = 'Link reset telah dikirim ke email.';
      });
    } catch (e) {
      setState(() {
        message = 'Gagal mengirim reset. Email tidak ditemukan.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Reset Password', style: TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            if (message.isNotEmpty)
              Text(message, style: const TextStyle(color: Colors.yellow)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: resetPassword,
              child: const Text('Kirim Link'),
            ),
          ],
        ),
      ),
    );
  }
}
