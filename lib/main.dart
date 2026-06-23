import 'package:flutter/material.dart';

// Mengimpor layar pertama (Login)
import 'ui/screens/auth/login_screen.dart';

void main() {
  runApp(const TenantHubApp());
}

class TenantHubApp extends StatelessWidget {
  // Diperbarui menggunakan super parameter untuk menghilangkan warning garis biru
  const TenantHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TenantHub',
      debugShowCheckedModeBanner: false,
      
      // Menerapkan tema global agar konsisten dan tidak perlu hardcode warna 
      // di setiap layar (mengurangi technical debt)
      theme: ThemeData(
        primaryColor: const Color(0xFF1A3353), // Biru gelap utama
        scaffoldBackgroundColor: Colors.grey[50], // Background default
        
        // Catatan: Penggunaan google_fonts telah dihapus dari sini agar 
        // tidak terjadi error merah. Aplikasi akan menggunakan font bawaan (Roboto).
        
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF1A3353),
          secondary: const Color(0xFF1A56A6), // Biru aksen (tombol, dll)
        ),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A3353),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A56A6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      
      // Menetapkan layar awal aplikasi
      home: const LoginScreen(),
    );
  }
}