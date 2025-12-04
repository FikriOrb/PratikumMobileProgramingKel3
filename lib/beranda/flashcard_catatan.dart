import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlashcardCatatanPage extends StatelessWidget {
  const FlashcardCatatanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101922), // Background Dark
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Tombol Kembali
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Judul
                  Expanded(
                    child: Text("Flash Card: Catatan", style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  // Tombol Tambah
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(color: Color(0xFF137FEC), shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),

            // --- List Konten ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text("Kelola rangkuman dan catatan penting.", style: GoogleFonts.lexend(fontSize: 16, color: const Color(0xFF9CA3AF))),
                  const SizedBox(height: 24),
                  _buildListItem("Apa itu Fotosintesis?"),
                  const SizedBox(height: 12),
                  _buildListItem("Sebutkan 3 komponen utama sel!"),
                  const SizedBox(height: 12),
                  _buildListItem("Definisi Globalisasi"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white))),
          const Icon(Icons.edit, size: 20, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 16),
          const Icon(Icons.delete, size: 20, color: Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}