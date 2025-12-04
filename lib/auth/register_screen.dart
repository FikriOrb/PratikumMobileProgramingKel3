import 'dart:convert'; // Untuk JSON
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Wajib import http
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false; // Indikator loading

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final Color bgDark = const Color(0xFF101922);
  final Color bgInput = const Color(0xFF1F2937);
  final Color primaryBlue = const Color(0xFF137FEC);
  final Color textGray = const Color(0xFF9CA3AF);

  // --- FUNGSI DAFTAR KE API ---
  Future<void> _handleRegister() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap isi semua kolom!"), backgroundColor: Colors.redAccent));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kata sandi tidak cocok!"), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // GANTI IP INI JIKA PAKAI HP ASLI (Misal: 192.168.1.X)
      // 10.0.2.2 adalah localhost khusus Emulator Android
      var url = Uri.parse('http://10.0.2.2/learnify_api/register.php');
      
      var response = await http.post(url, body: {
        'username': name,
        'email': email,
        'password': password,
      });

      var data = jsonDecode(response.body);

      if (data['success'] == true) {
        // SUKSES
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.green));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else {
        // GAGAL (Email sudah ada, dll)
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Buat Akun Baru", style: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text("Mulai belajar dan raih hadiah harianmu.", style: GoogleFonts.lexend(fontSize: 14, color: textGray)),
                const SizedBox(height: 32),

                _buildLabel("Nama Lengkap"),
                _buildTextField(controller: _nameController, hint: "Masukkan nama lengkap", icon: Icons.person_outline),
                const SizedBox(height: 16),

                _buildLabel("Email"),
                _buildTextField(controller: _emailController, hint: "Masukkan alamat email", icon: Icons.email_outlined),
                const SizedBox(height: 16),

                _buildLabel("Kata Sandi"),
                _buildPasswordField(controller: _passwordController, hint: "Masukkan kata sandi", isVisible: _isPasswordVisible, onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
                const SizedBox(height: 16),

                _buildLabel("Konfirmasi Kata Sandi"),
                _buildPasswordField(controller: _confirmPasswordController, hint: "Ulangi kata sandi", isVisible: _isConfirmPasswordVisible, onToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Daftar", style: GoogleFonts.lexend(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Sudah punya akun? ", style: GoogleFonts.lexend(color: textGray)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                      child: Text("Masuk", style: GoogleFonts.lexend(color: primaryBlue, fontWeight: FontWeight.bold)),
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

  Widget _buildLabel(String label) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w500)));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: textGray), hintText: hint, hintStyle: TextStyle(color: textGray), filled: true, fillColor: bgInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPasswordField({required TextEditingController controller, required String hint, required bool isVisible, required VoidCallback onToggle}) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_outline, color: textGray), hintText: hint, hintStyle: TextStyle(color: textGray), filled: true, fillColor: bgInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: IconButton(icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: textGray), onPressed: onToggle),
      ),
    );
  }
}