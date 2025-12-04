import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../user_data.dart';

class FlashcardAutoplayPage extends StatefulWidget {
  final String deckId; 

  const FlashcardAutoplayPage({super.key, required this.deckId});

  @override
  State<FlashcardAutoplayPage> createState() => _FlashcardAutoplayPageState();
}

class _FlashcardAutoplayPageState extends State<FlashcardAutoplayPage> {
  final PageController _pageController = PageController();
  double _currentPageValue = 0.0;
  Timer? _timer;
  bool _isPlaying = false;
  double _timerProgress = 0.0;
  final int _durationSeconds = 4;

  final Color bgDark = const Color(0xFF101922);
  final Color textGray = const Color(0xFF9CA3AF);
  final Color primaryBlue = const Color(0xFF137FEC);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() { _currentPageValue = _pageController.page!; });
    });
  }

  @override
  void dispose() {
    _stopAutoplay();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoplay(int length) {
    if (length == 0) return;
    setState(() { _isPlaying = true; });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _timerProgress += 0.1 / _durationSeconds;
        if (_timerProgress >= 1.0) {
          _timerProgress = 0.0;
          _nextPageOrLoop(length);
        }
      });
    });
  }

  void _stopAutoplay() {
    _timer?.cancel();
    setState(() { _isPlaying = false; _timerProgress = 0.0; });
  }

  void _nextPageOrLoop(int length) {
    int currentIndex = _currentPageValue.round();
    if (currentIndex < length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
    } else {
      _pageController.animateToPage(0, duration: const Duration(milliseconds: 800), curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
      builder: (context, userData, child) {
        var deck = userData.getDeckById(widget.deckId);
        
        // --- 1. AMBIL SKIN ---
        var skin = userData.activeSkin;

        if (deck.isEmpty) return const Scaffold(body: Center(child: Text("Topik tidak ditemukan")));

        String judulTopik = deck['title'];
        List<String> listAutoplay = List<String>.from(deck['cards']);

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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                Text("Autoplay Mode", style: GoogleFonts.lexend(fontSize: 12, color: textGray)), 
                                Text(judulTopik, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))
                              ]
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (listAutoplay.isNotEmpty) 
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: _isPlaying ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2), 
                                shape: BoxShape.circle, 
                                border: Border.all(color: _isPlaying ? Colors.green : Colors.orange, width: 2)
                              ), 
                              child: Icon(_isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 20, color: _isPlaying ? Colors.green : Colors.orange)
                            ),
                        ],
                      ),
                    ),

                    // PROGRESS BAR
                    if (listAutoplay.isNotEmpty) 
                      LinearProgressIndicator(value: _timerProgress, backgroundColor: Colors.white.withOpacity(0.05), color: primaryBlue, minHeight: 4),
                    
                    const SizedBox(height: 16),

                    // CONTENT
                    Expanded(
                      child: listAutoplay.isEmpty
                          ? Center(child: Text("Data Kosong", style: TextStyle(color: textGray)))
                          : PageView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              controller: _pageController,
                              itemCount: listAutoplay.length,
                              itemBuilder: (context, index) {
                                // --- 2. OPER DATA SKIN ---
                                return _buildFlipAnimation(index, _buildAutoCard(index, listAutoplay[index], skin));
                              },
                            ),
                    ),

                    // CONTROL
                    if (listAutoplay.isNotEmpty) 
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40), 
                        child: Center(
                          child: InkWell(
                            onTap: () { if (_isPlaying) { _stopAutoplay(); } else { _startAutoplay(listAutoplay.length); } }, 
                            borderRadius: BorderRadius.circular(50), 
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200), 
                              width: 72, height: 72, 
                              decoration: BoxDecoration(
                                color: _isPlaying ? Colors.redAccent : primaryBlue, 
                                shape: BoxShape.circle, 
                                boxShadow: [BoxShadow(color: (_isPlaying ? Colors.redAccent : primaryBlue).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))]
                              ), 
                              child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow_rounded, color: Colors.white, size: 36)
                            )
                          )
                        )
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

  // --- 3. TERIMA DAN PAKAI SKIN ---
  Widget _buildAutoCard(int index, String text, Map<String, dynamic> skin) {
    return Container(
      width: double.infinity, 
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), 
      decoration: BoxDecoration(
        color: skin['color'], // Warna Skin
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: skin['border'], width: 2), // Border Skin
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]
      ), 
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32), 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  Icon(Icons.play_circle_outline, color: skin['textColor'].withOpacity(0.3), size: 40), 
                  const SizedBox(height: 24), 
                  Text(
                    text, 
                    textAlign: TextAlign.center, 
                    style: GoogleFonts.lexend(
                      color: skin['textColor'], // Text Color Skin
                      fontSize: 22, 
                      fontWeight: FontWeight.w500, 
                      height: 1.5
                    )
                  )
                ]
              )
            )
          ), 
          Positioned(
            bottom: 16, right: 16, 
            child: Text(
              "${index + 1}", 
              style: GoogleFonts.lexend(color: skin['textColor'].withOpacity(0.5), fontSize: 32, fontWeight: FontWeight.bold)
            )
          )
        ]
      )
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