import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../user_data.dart';

class FlashcardGambarViewPage extends StatefulWidget {
  final String albumId; 

  const FlashcardGambarViewPage({super.key, required this.albumId});

  @override
  State<FlashcardGambarViewPage> createState() => _FlashcardGambarViewPageState();
}

class _FlashcardGambarViewPageState extends State<FlashcardGambarViewPage> {
  final PageController _pageController = PageController();
  double _currentPageValue = 0.0;
  final Color bgDark = const Color(0xFF101922);
  final Color primaryPurple = const Color(0xFFA855F7);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() { setState(() { _currentPageValue = _pageController.page!; }); });
    WidgetsBinding.instance.addPostFrameCallback((_) { context.read<UserData>().addStudyDuration(2); });
  }

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  void _nextPage(int length) { if (_currentPageValue < length - 1) _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic); }
  void _prevPage() { if (_currentPageValue > 0) _pageController.previousPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic); }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
      builder: (context, userData, child) {
        var album = userData.getImageAlbumById(widget.albumId);
        if (album.isEmpty) return const Scaffold(body: Center(child: Text("Album tidak ditemukan")));

        String judulTopik = album['title'];
        List<Map<String, String>> daftarItem = [];
        if (album['items'] != null) {
          for (var item in album['items']) daftarItem.add(Map<String, String>.from(item));
        }

        int currentIndex = _currentPageValue.round();
        double progressValue = daftarItem.isEmpty ? 0 : (currentIndex + 1) / daftarItem.length;

        return Scaffold(
          backgroundColor: bgDark,
          body: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: GridPainter())),
              SafeArea(
                child: Column(
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white))), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Lihat Kartu", style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey)), Text(judulTopik, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis)])), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text("${currentIndex + 1}/${daftarItem.length}", style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold)))])) ,
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progressValue, backgroundColor: Colors.white.withOpacity(0.1), color: primaryPurple, minHeight: 4))),
                    const SizedBox(height: 16),
                    
                    Expanded(
                      child: daftarItem.isEmpty 
                        ? Center(child: Text("Belum ada gambar", style: GoogleFonts.lexend(color: Colors.white)))
                        : PageView.builder(
                            scrollDirection: Axis.vertical, 
                            controller: _pageController,
                            itemCount: daftarItem.length,
                            itemBuilder: (context, index) {
                              return _buildFlipAnimation(index, _buildCard(daftarItem[index]));
                            },
                          ),
                    ),

                    Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [IconButton(onPressed: (currentIndex > 0) ? _prevPage : null, icon: Icon(Icons.keyboard_arrow_up, color: (currentIndex > 0) ? Colors.white : Colors.white24), iconSize: 36), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryPurple.withOpacity(0.2), shape: BoxShape.circle), child: Icon(Icons.image, color: primaryPurple, size: 24)), IconButton(onPressed: (currentIndex < daftarItem.length - 1) ? () => _nextPage(daftarItem.length) : null, icon: Icon(Icons.keyboard_arrow_down, color: (currentIndex < daftarItem.length - 1) ? Colors.white : Colors.white24), iconSize: 36)])),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildFlipAnimation(int index, Widget child) {
    double value = (index - _currentPageValue);
    final double rotation = value.clamp(-1.0, 1.0); 
    final Matrix4 matrix = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(rotation * -1.0); 
    final double opacity = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
    return Transform(transform: matrix, alignment: Alignment.topCenter, child: Opacity(opacity: opacity, child: child));
  }

  Widget _buildCard(Map<String, String> item) {
    return Consumer<UserData>(
      builder: (context, userData, child) {
        var skin = userData.activeSkin;
        
        // --- AMBIL DESKRIPSI (Gunakan default jika null) ---
        String deskripsi = item['desc'] ?? "Tidak ada deskripsi.";

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: skin['color'], 
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: skin['border'], width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: Stack(fit: StackFit.expand, children: [Image.network(item['img']!, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.white54, size: 50))), Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]))), Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(item['name']!, textAlign: TextAlign.center, style: GoogleFonts.lexend(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 2))]))))])),
                
                // --- TAMPILAN DESKRIPSI ---
                Expanded(
                  flex: 4, 
                  child: Container(
                    width: double.infinity, 
                    color: skin['color'], 
                    padding: const EdgeInsets.all(24), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        Text("Deskripsi", style: GoogleFonts.lexend(color: skin['textColor'], fontSize: 14, fontWeight: FontWeight.w600)), 
                        const SizedBox(height: 12), 
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(), 
                            // Tampilkan variabel deskripsi
                            child: Text(
                              deskripsi, 
                              style: GoogleFonts.lexend(color: skin['textColor'].withOpacity(0.9), fontSize: 16, height: 1.6)
                            )
                          )
                        )
                      ]
                    )
                  )
                ),
              ],
            ),
          ),
        );
      }
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