import 'package:flutter/material.dart';
import 'login_page.dart'; // Ganti sesuai nama file login kamu

class LoadingLogo extends StatefulWidget {
  const LoadingLogo({super.key});

  @override
  State<LoadingLogo> createState() => _LoadingLogoState();
}

class _LoadingLogoState extends State<LoadingLogo> {
  @override
  void initState() {
    super.initState();

    // Delay selama 2 detik, lalu pindah ke LoginPage
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage('assets/swapu.png'), // Pastikan gambar ini ada di pubspec.yaml
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.yellow,
            ),
          ],
        ),
      ),
    );
  }
}
