import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'loading_logo.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';
import 'verification_page.dart';
import 'new_password_page.dart';
import 'dashboard_page.dart';
import 'chat_page.dart';
import 'chat_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow, width: 2),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoadingLogo(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/forgot-password': (_) => const ForgotPasswordPage(),
        '/verification': (_) => const VerificationPage(),
        '/new-password': (_) => const NewPasswordPage(),
        '/dashboard': (_) => const DashboardPage(),
        '/chat': (_) => const ChatPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chatDetail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ChatDetailPage(
              chatId: args['chatId'],
              otherUserId: args['otherUserId'],
            ),
          );
        }

        // Fallback jika route tidak dikenal
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                'Halaman tidak ditemukan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
