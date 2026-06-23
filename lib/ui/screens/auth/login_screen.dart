import 'package:flutter/material.dart';
import '../home_screen.dart'; // Asumsi HomeScreen ada di direktori induk (ui/screens/)
// import '../../data/api_service.dart'; // TODO: Uncomment ini setelah file api_service dibuat

// --- MOCK API SERVICE (Hanya untuk keperluan kompilasi sementara) ---
// Dalam implementasi nyata, letakkan ini di lib/data/api_service.dart
class ApiService {
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulasi network
    if (email == 'tenant@acmemall.com' && password == 'password123') {
      return true; // Berhasil
    } else {
      throw Exception('Email atau password tidak valid.');
    }
  }
}
// ------------------------------------------------------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // Diperbarui menggunakan super.key

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); 
  
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false; 

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Instansiasi service (idealnya di-inject melalui Provider/GetIt)
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Logika login sekarang didelegasikan ke ApiService
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; 
      });

      try {
        // Pendelegasian logika ke layer data (ApiService)
        final isSuccess = await _apiService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!mounted) return;

        if (isSuccess) {
          // Navigasi ke HomeScreen menggunakan PageRouteBuilder agar error hilang
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        // Menampilkan pesan error spesifik dari service
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red[700],
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; 
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3353),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        children: [
                          TextSpan(text: 'TENANT', style: TextStyle(color: Colors.white)),
                          TextSpan(text: 'HUB', style: TextStyle(color: Color(0xFF4DB6AC))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Smart Tenant Operations Platform',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              flex: 7,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selamat datang!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        
                        const Text('Email atau Username', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          enabled: !_isLoading, 
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email/Username tidak boleh kosong';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'tenant@acmemall.com',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          enabled: !_isLoading, 
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  height: 24, width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: _isLoading ? null : (value) => setState(() => _rememberMe = value ?? false),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Ingat saya', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            TextButton(
                              onPressed: _isLoading ? null : () {},
                              child: const Text('Lupa password?', style: TextStyle(color: Color(0xFF1A56A6), fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A56A6),
                              disabledBackgroundColor: Colors.grey[400],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                            child: _isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('atau masuk dengan', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : () {},
                            icon: _buildGoogleIcon(), 
                            label: const Text('Masuk dengan SSO', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20, height: 20,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: const Center(
        child: Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}