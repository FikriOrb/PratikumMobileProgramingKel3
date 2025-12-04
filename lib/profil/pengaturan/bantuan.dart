import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  final Color bgDark = const Color(0xFF101922);
  final Color bgCardDark = const Color(0xFF1F2937);

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
          "Bantuan & Dukungan",
          style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Search Bar Sederhana
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: bgCardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                icon: const Icon(Icons.search, color: Colors.white54),
                hintText: "Cari masalah...",
                hintStyle: GoogleFonts.lexend(color: Colors.white30),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Menu Bantuan
          _buildItem("Pusat Bantuan (FAQ)", Icons.help_outline),
          _buildItem("Hubungi Kami", Icons.support_agent),
          _buildItem("Laporkan Bug", Icons.bug_report_outlined),
          _buildItem("Beri Rating Aplikasi", Icons.star_border),
          
          const SizedBox(height: 24),
          
          // Info Versi
          Center(
            child: Text(
              "Versi 1.0.0 (Beta)",
              style: GoogleFonts.lexend(color: Colors.white24, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgCardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: GoogleFonts.lexend(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: () {},
      ),
    );
  }
}