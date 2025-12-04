import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_screen.dart'; // Pastikan import ini ada

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer: Pindah halaman setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF137FEC), // Warna Biru Utama
      body: Stack(
        children: [
          // --- Dekorasi Background (Lingkaran Samar) ---
          Positioned(
            top: -50, left: -50,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: 100, right: -50,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            ),
          ),

          // --- Konten Tengah ---
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo (Lingkaran Putih + Topi Toga)
                Container(
                  width: 120, height: 120,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.school_rounded, size: 60, color: Color(0xFF137FEC)),
                ),
                const SizedBox(height: 24),
                
                // Nama Aplikasi
                Text(
                  "Learnify",
                  style: GoogleFonts.lexend(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  "Buka potensi belajarmu, setiap hari.",
                  style: GoogleFonts.lexend(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          // --- Loading Indicator di Bawah ---
          Positioned(
            bottom: 50,
            left: 0, right: 0,
            child: Column(
              children: [
                const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                ),
                const SizedBox(height: 16),
                Text("Memuat...", style: GoogleFonts.lexend(color: Colors.white70, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }
}