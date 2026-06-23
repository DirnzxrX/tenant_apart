import 'package:flutter/material.dart';
import 'dart:async';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // TANTANGAN ARSITEKTURAL:
    // Di sinilah nanti Anda harus menempatkan logika pengecekan token.
    // Contoh: 
    // final token = await SecureStorage.getToken();
    // if (token != null) -> Navigasi ke HomeScreen
    // else -> Navigasi ke LoginScreen
    
    // Saat ini, kita hanya melakukan simulasi loading selama 3 detik.
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Menerapkan solusi alternatif yang sama dengan di Profile Screen
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3353), // Biru gelap utama TenantHub
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Utama
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                children: [
                  TextSpan(text: 'TENANT', style: TextStyle(color: Colors.white)),
                  TextSpan(text: 'HUB', style: TextStyle(color: Color(0xFF4DB6AC))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Smart Tenant Operations Platform',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 64),
            // Indikator Loading
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4DB6AC)),
            ),
          ],
        ),
      ),
    );
  }
}