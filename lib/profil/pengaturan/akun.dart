import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../user_data.dart'; // Import UserData
// Import Halaman Login untuk redirect setelah hapus akun
import '../../auth/login_screen.dart'; 

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  final Color bgDark = const Color(0xFF101922);
  final Color bgCardDark = const Color(0xFF1F2937);
  final Color primaryColor = const Color(0xFF137FEC);

  // --- DIALOG GANTI PASSWORD ---
  void _showChangePasswordDialog(BuildContext context) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    // Variabel state untuk visibilitas password
    // Kita inisialisasi di dalam fungsi agar reset setiap dialog dibuka
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder digunakan agar Dialog bisa me-refresh UI (icon mata)
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: bgCardDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Ganti Kata Sandi", style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 20),
                      
                      // Input Password Lama
                      _buildPasswordField(
                        "Kata Sandi Lama", 
                        oldPassCtrl, 
                        obscureOld, 
                        () => setStateDialog(() => obscureOld = !obscureOld)
                      ),
                      const SizedBox(height: 16),
                      
                      // Input Password Baru
                      _buildPasswordField(
                        "Kata Sandi Baru", 
                        newPassCtrl, 
                        obscureNew, 
                        () => setStateDialog(() => obscureNew = !obscureNew)
                      ),
                      const SizedBox(height: 16),
                      
                      // Input Konfirmasi
                      _buildPasswordField(
                        "Konfirmasi Kata Sandi", 
                        confirmPassCtrl, 
                        obscureConfirm, 
                        () => setStateDialog(() => obscureConfirm = !obscureConfirm)
                      ),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () {
                            // LOGIKA VALIDASI
                            final userData = context.read<UserData>();
                            String oldPass = oldPassCtrl.text;
                            String newPass = newPassCtrl.text;
                            String confirmPass = confirmPassCtrl.text;

                            if (oldPass.isEmpty || newPass.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua kolom harus diisi!")));
                              return;
                            }

                            if (!userData.validatePassword(oldPass)) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kata sandi lama salah!"), backgroundColor: Colors.red));
                              return;
                            }

                            if (newPass != confirmPass) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Konfirmasi kata sandi tidak cocok!"), backgroundColor: Colors.red));
                              return;
                            }

                            // SUKSES
                            userData.changePassword(newPass);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kata sandi berhasil diubah!"), backgroundColor: Colors.green));
                          },
                          child: Text("Simpan", style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  // --- WIDGET INPUT PASSWORD DENGAN MATA ---
  Widget _buildPasswordField(String label, TextEditingController controller, bool isObscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: isObscure, // Menggunakan state
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true, fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            // Tombol Mata (Suffix Icon)
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility, 
                color: Colors.grey
              ),
              onPressed: onToggle, // Panggil fungsi toggle
            ),
          ),
        ),
      ],
    );
  }

  // --- DIALOG HAPUS AKUN ---
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgCardDark,
        title: Text("Hapus Akun?", style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          "Apakah Anda yakin ingin menghapus akun ini secara permanen? Semua data (Koin, Catatan, Misi) akan hilang dan tidak dapat dikembalikan.",
          style: GoogleFonts.lexend(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.lexend(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              // 1. Panggil fungsi reset di UserData
              context.read<UserData>().deleteAccount();
              
              // 2. Tutup Dialog
              Navigator.pop(context);

              // 3. Pindah ke Halaman Login & Hapus History Navigasi
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const LoginScreen()), 
                (route) => false
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Akun berhasil dihapus."), backgroundColor: Colors.redAccent)
              );
            },
            child: Text("Hapus Permanen", style: GoogleFonts.lexend(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text("Akun", style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 1. Ganti Kata Sandi
          _buildItem(
            "Ganti Kata Sandi", 
            Icons.lock_outline, 
            onTap: () => _showChangePasswordDialog(context)
          ),
          
          _buildItem("Kelola Perangkat", Icons.devices, onTap: (){}),
          _buildItem("Bahasa", Icons.language, onTap: (){}),
          const SizedBox(height: 24),
          
          // 2. Hapus Akun
          _buildItem(
            "Hapus Akun", 
            Icons.delete_forever, 
            isDanger: true, 
            onTap: () => _showDeleteAccountDialog(context)
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, IconData icon, {bool isDanger = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: bgCardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDanger ? Colors.redAccent.withOpacity(0.5) : Colors.white10)),
        child: ListTile(
          leading: Icon(icon, color: isDanger ? Colors.redAccent : Colors.white70),
          title: Text(title, style: GoogleFonts.lexend(color: isDanger ? Colors.redAccent : Colors.white)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        ),
      ),
    );
  }
}