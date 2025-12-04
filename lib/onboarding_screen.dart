import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import halaman Login yang ada di folder auth
import 'auth/login_screen.dart'; 

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Data Slide Onboarding
  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Belajar dan Raih\nHadiah Setiap Hari",
      "desc": "Kumpulkan koin dengan login harian dan selesaikan misi untuk mendapatkan reward menarik.",
    },
    {
      "title": "Tingkatkan Pengetahuanmu\ndengan Flash Card",
      "desc": "Belajar lebih efektif dengan berbagai jenis flash card. Pilih gaya belajar yang paling cocok untukmu!",
    },
    {
      "title": "Pantau Progres\nBelajarmu",
      "desc": "Lihat statistik perkembangan belajarmu dan jadilah yang terbaik di antara teman-temanmu.",
    },
  ];

  // Warna Tema
  final Color bgDark = const Color(0xFF101922);
  final Color primaryBlue = const Color(0xFF137FEC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(
        children: [
          // 1. Background Grid Pattern
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          Column(
            children: [
              // --- PAGE VIEW (SLIDER) ---
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildPageContent(
                      _onboardingData[index]["title"]!,
                      _onboardingData[index]["desc"]!,
                      index,
                    );
                  },
                ),
              ),

              // --- BAGIAN BAWAH (NAVIGASI) ---
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Back (Sembunyi jika di halaman pertama)
                    if (_currentIndex > 0)
                      TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300), 
                            curve: Curves.easeInOut
                          );
                        },
                        child: Text("Back", style: GoogleFonts.lexend(color: Colors.grey, fontWeight: FontWeight.bold)),
                      )
                    else
                      const SizedBox(width: 60), // Placeholder agar layout seimbang

                    // Indikator Titik (Dots)
                    Row(
                      children: List.generate(_onboardingData.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentIndex == index ? 24 : 8, // Memanjang jika aktif
                          decoration: BoxDecoration(
                            color: _currentIndex == index ? primaryBlue : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    // Tombol Next / Mulai
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        if (_currentIndex < _onboardingData.length - 1) {
                          // Geser ke halaman berikutnya
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300), 
                            curve: Curves.easeInOut
                          );
                        } else {
                          // Jika halaman terakhir -> Pindah ke Login Screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      },
                      child: Text(
                        _currentIndex == _onboardingData.length - 1 ? "Mulai" : "Next",
                        style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20), // Jarak aman bawah
            ],
          ),
        ],
      ),
    );
  }

  // Widget Konten Per Halaman (Ilustrasi + Teks)
  Widget _buildPageContent(String title, String desc, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustrasi (Menggunakan Icon & Container Mockup)
          Container(
            height: 250, width: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937), // Card color gelap
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ilustrasi Mockup Sederhana sesuai index halaman
                if (index == 0) // Halaman 1: Reward
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.savings_outlined, size: 80, color: Colors.orangeAccent),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text("+100 Coins", style: GoogleFonts.lexend(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                
                if (index == 1) // Halaman 2: Flashcard
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(angle: -0.15, child: Container(width: 140, height: 180, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)))),
                      Transform.rotate(angle: 0.1, child: Container(width: 140, height: 180, decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.style, size: 60, color: Colors.white))),
                    ],
                  ),
                
                if (index == 2) // Halaman 3: Chart/Progres
                  const Icon(Icons.bar_chart_rounded, size: 100, color: Colors.greenAccent),
              ],
            ),
          ),
          
          const SizedBox(height: 40),

          // Teks Judul
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
          ),
          
          const SizedBox(height: 16),

          // Teks Deskripsi
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// Helper Grid Painter (Untuk Background Kotak-kotak)
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    const double gridSize = 24.0;
    for (double x = 0; x < size.width; x += gridSize) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += gridSize) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}