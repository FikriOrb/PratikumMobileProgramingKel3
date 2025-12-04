import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Import http
import 'package:provider/provider.dart'; // Import Provider
import '../../user_data.dart'; // Import UserData
import 'register_screen.dart'; 
import '../beranda/beranda.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final Color bgDark = const Color(0xFF101922);
  final Color bgInput = const Color(0xFF1F2937);
  final Color primaryBlue = const Color(0xFF137FEC);
  final Color textGray = const Color(0xFF9CA3AF);

  // --- FUNGSI LOGIN KE API ---
  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap isi email dan kata sandi!"), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // GANTI IP DISINI JIKA PAKAI HP ASLI
      var url = Uri.parse('http://10.0.2.2/learnify_api/login.php');
      
      var response = await http.post(url, body: {
        'email': email,
        'password': password,
      });

      var data = jsonDecode(response.body);

      if (data['success'] == true) {
        // 1. Ambil data user dari respon JSON
        var userDataMap = data['data'];

        // 2. Simpan ke Provider (User Data)
        // Pastikan fungsi setUserDataFromApi SUDAH DITAMBAHKAN di user_data.dart
        if (!mounted) return;
        context.read<UserData>().setUserDataFromApi(userDataMap);

        // 3. Masuk ke Beranda
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Berhasil!"), backgroundColor: Colors.green));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BerandaPage()));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal terhubung ke server!"), backgroundColor: Colors.redAccent));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 200, width: 200,
                  decoration: BoxDecoration(color: const Color(0xFFEAD4AA), borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.lightbulb_outline, size: 80, color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Text("Selamat Datang Kembali!", textAlign: TextAlign.center, style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 32),
                
                Align(alignment: Alignment.centerLeft, child: Text("Email", style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w500))),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Masukkan email", hintStyle: TextStyle(color: textGray), filled: true, fillColor: bgInput,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),

                Align(alignment: Alignment.centerLeft, child: Text("Kata Sandi", style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w500))),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Masukkan kata sandi", hintStyle: TextStyle(color: textGray), filled: true, fillColor: bgInput,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: textGray),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),

                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: Text("Lupa Kata Sandi?", style: GoogleFonts.lexend(color: primaryBlue, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Masuk", style: GoogleFonts.lexend(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Belum punya akun? ", style: GoogleFonts.lexend(color: textGray)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                      child: Text("Daftar", style: GoogleFonts.lexend(color: primaryBlue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}