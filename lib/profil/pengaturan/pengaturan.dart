import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import sub-halaman (akan kita buat setelah ini)
import 'edit_profil.dart';
import 'akun.dart';
import 'notifikasi.dart';
import 'privasi.dart';
import 'bantuan.dart';
import '../../auth/login_screen.dart'; // Untuk Logout

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Palet Warna Konsisten
  final Color bgDark = const Color(0xFF101922);
  final Color bgCardDark = const Color(0xFF1F2937);
  final Color textGray = const Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // ===== APP BAR =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Pengaturan',
                        style: TextStyle( // Pake TextStyle biasa biar const aman, atau GoogleFonts tanpa const
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lexend', // Pastikan font terload, atau gunakan GoogleFonts
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Spacer penyeimbang
                ],
              ),
            ),

            // ===== LIST PENGATURAN =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    _buildTile(
                      context,
                      icon: Icons.person_outline,
                      title: 'Edit Profil',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfilePage())),
                    ),
                    const SizedBox(height: 12),
                    _buildTile(
                      context,
                      icon: Icons.manage_accounts_outlined,
                      title: 'Pengaturan Akun',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsPage())),
                    ),
                    const SizedBox(height: 12),
                    _buildTile(
                      context,
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifikasi',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationSettingsPage())),
                    ),
                    const SizedBox(height: 12),
                    _buildTile(
                      context,
                      icon: Icons.shield_outlined,
                      title: 'Privasi',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPage())),
                    ),
                    const SizedBox(height: 12),
                    _buildTile(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: 'Bantuan & Dukungan',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportPage())),
                    ),
                    const SizedBox(height: 24),
                    _buildLogoutTile(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgCardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutTile(BuildContext context) {
    return InkWell(
      onTap: () {
        // Logika Logout: Kembali ke Login Screen & Hapus History Navigasi
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
            const SizedBox(width: 14),
            Text(
              'Keluar',
              style: GoogleFonts.lexend(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}