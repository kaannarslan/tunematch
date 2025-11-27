import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Login ekranını import ettik

void main() {
  runApp(const MusicMatchApp());
}

class MusicMatchApp extends StatelessWidget {
  const MusicMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Müzik Eşleşmesi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        // Input dekorasyonlarını global olarak buradan da yönetebiliriz
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black12),
          ),
        ),
      ),
      // ARTIK BURASI LOGIN SCREEN OLUYOR
      home: const LoginScreen(),
    );
  }
}
