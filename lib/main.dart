import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/barang_screen.dart'; // Tambahan

void main() {
  runApp(const FindoraApp());
}

class FindoraApp extends StatelessWidget {
  const FindoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'finDora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.pink[200],
        scaffoldBackgroundColor: const Color(0xFFF8E8E8),
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/barang': (context) => const BarangScreen(), // Tambahan
      },
    );
  }
}
