import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../user_data.dart';

class FlashcardReviewPage extends StatefulWidget {
  final String deckId; 

  const FlashcardReviewPage({super.key, required this.deckId});

  @override
  State<FlashcardReviewPage> createState() => _FlashcardReviewPageState();
}

class _FlashcardReviewPageState extends State<FlashcardReviewPage> {
  final PageController _pageController = PageController();
  double _currentPageValue = 0.0;
  final Color bgDark = const Color(0xFF101922);
  final Color textGray = const Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() { _currentPageValue = _pageController.page!; });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<UserData>().addStudyDuration(2);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
      builder: (context, userData, child) {
        var deck = userData.getDeckById(widget.deckId);
        
        // --- 1. AMBIL SKIN AKTIF ---
        var skin = userData.activeSkin; 

        if (deck.isEmpty) return const Scaffold(body: Center(child: Text("Topik tidak ditemukan")));

        String judulTopik = deck['title'];
        List<String> listReview = List<String>.from(deck['cards']);
        
        // Logika Infinite Scroll
        int totalData = listReview.length;
        int realIndex = totalData == 0 ? 0 : (_currentPageValue.round() % totalData);
        double progressValue = totalData == 0 ? 0 : (realIndex + 1) / totalData;

        void nextPage() {
          if (listReview.isNotEmpty) {
            _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
          }
        }
        
        void prevPage() {
          if (_currentPageValue.round() > 0) {
            _pageController.previousPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
          }
        }

        return Scaffold(
          backgroundColor: bgDark,
          body: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: GridPainter())),
              SafeArea(
                child: Column(
                  children: [
                    // HEADER
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context), 
                            borderRadius: BorderRadius.circular(20), 
                            child: Container(
                              padding: const EdgeInsets.all(8), 
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), 
                              child: const Icon(Icons.close, color: Colors.white)
                            )
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [
                              Text("Review Mode", style: GoogleFonts.lexend(fontSize: 12, color: textGray)), 
                              Text(judulTopik, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))
                            ]
                          ),
                        ],
                      ),
                    ),

                    // PROGRESS BAR
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4), 
                            child: LinearProgressIndicator(value: progressValue, backgroundColor: Colors.white.withOpacity(0.1), color: Colors.greenAccent, minHeight: 6)
                          ),
                          const SizedBox(height: 8),
                          Text(
                            listReview.isEmpty ? "0/0" : "${realIndex + 1}/$totalData", 
                            style: GoogleFonts.lexend(color: textGray, fontSize: 12)
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // CONTENT
                    Expanded(
                      child: listReview.isEmpty
                          ? Center(child: Text("Belum ada catatan.\nIsi dulu di menu Pelajari.", textAlign: TextAlign.center, style: TextStyle(color: textGray)))
                          : PageView.builder(
                              scrollDirection: Axis.vertical,
                              controller: _pageController,
                              itemBuilder: (context, index) {
                                int dataIndex = index % totalData;
                                // --- 2. OPER DATA SKIN KE KARTU ---
                                return _buildFlipAnimation(index, _buildReviewCard(dataIndex, listReview[dataIndex], dataIndex, skin));
                              },
                            ),
                    ),
                    
                    // NAVIGASI BAWAH
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: (listReview.isNotEmpty && _currentPageValue.round() > 0) ? prevPage : null, 
                            icon: Icon(Icons.keyboard_arrow_up, color: (listReview.isNotEmpty && _currentPageValue.round() > 0) ? Colors.white : Colors.white24), 
                            iconSize: 36
                          ),
                          Container(
                            width: 50, height: 50, 
                            decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), shape: BoxShape.circle), 
                            child: const Icon(Icons.style, color: Colors.greenAccent, size: 24)
                          ),
                          IconButton(
                            onPressed: listReview.isNotEmpty ? nextPage : null, 
                            icon: Icon(Icons.keyboard_arrow_down, color: listReview.isNotEmpty ? Colors.white : Colors.white24), 
                            iconSize: 36
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlipAnimation(int index, Widget child) {
    double value = (index - _currentPageValue);
    final double rotation = value.clamp(-1.0, 1.0);
    final Matrix4 matrix = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(rotation * -1.0);
    final double opacity = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
    return Transform(transform: matrix, alignment: Alignment.topCenter, child: Opacity(opacity: opacity, child: child));
  }

  // --- 3. TERIMA PARAMETER SKIN & PAKAI WARNANYA ---
  Widget _buildReviewCard(int index, String text, int realIndex, Map<String, dynamic> skin) {
    return Container(
      width: double.infinity, 
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: skin['color'], // Pakai warna Skin
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: skin['border'], width: 2), // Pakai border Skin
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    Icon(Icons.auto_stories, color: skin['textColor'].withOpacity(0.5), size: 32), // Ikon menyesuaikan text
                    const SizedBox(height: 24), 
                    Text(
                      text, 
                      textAlign: TextAlign.center, 
                      style: GoogleFonts.lexend(
                        color: skin['textColor'], // Pakai text color Skin
                        fontSize: 22, 
                        fontWeight: FontWeight.w500, 
                        height: 1.5
                      )
                    )
                  ]
                )
              ),
            ),
          ),
          Positioned(
            bottom: 16, right: 16, 
            child: Text(
              "#${realIndex + 1}", 
              style: GoogleFonts.lexend(color: skin['textColor'].withOpacity(0.5), fontSize: 24, fontWeight: FontWeight.bold)
            )
          ),
        ],
      ),
    );
  }
}

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