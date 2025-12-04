import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../user_data.dart'; // Import UserData

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  final Color bgDark = const Color(0xFF101922);
  final Color bgCardDark = const Color(0xFF1F2937);
  final Color primaryColor = const Color(0xFF137FEC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Notifikasi",
          style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<UserData>( // Gunakan Consumer
        builder: (context, userData, child) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Opsi 1: Notifikasi Belajar
              _buildSwitch(
                "Notifikasi Belajar", 
                "Pengingat harian", 
                userData.studyReminder, // Ambil dari Provider
                (v) => userData.toggleStudyReminder(v) // Ubah ke Provider
              ),
              
              const SizedBox(height: 12),
              
              // Opsi 2: Suara Efek
              _buildSwitch(
                "Suara Efek", 
                "Suara saat klik tombol", 
                userData.soundEffects, // Ambil dari Provider
                (v) => userData.toggleSoundEffects(v) // Ubah ke Provider
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.lexend(color: Colors.white, fontSize: 16)),
              Text(subtitle, style: GoogleFonts.lexend(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }
}