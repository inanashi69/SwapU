import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _isEmailVerified = false;
  bool _isLoading = false;
  late final User? _user;
  late final FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser;
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    await _user?.reload();
    setState(() {
      _isEmailVerified = _auth.currentUser?.emailVerified ?? false;
    });
  }

  Future<void> _sendVerificationEmail() async {
    setState(() => _isLoading = true);
    try {
      await _user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildVerifiedContent() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified, color: Colors.yellow, size: 100),
        SizedBox(height: 20),
        Text(
          'Your email is verified!',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildUnverifiedContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.email, color: Colors.yellow, size: 100),
        const SizedBox(height: 20),
        const Text(
          'Please verify your email address.',
          style: TextStyle(color: Colors.white, fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendVerificationEmail,
          child: _isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                )
              : const Text('Send Verification Email'),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _checkEmailVerification,
          child: const Text(
            'I have verified my email',
            style: TextStyle(color: Colors.yellow),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Email Verification', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isEmailVerified
              ? _buildVerifiedContent()
              : _buildUnverifiedContent(),
        ),
      ),
    );
  }
}
