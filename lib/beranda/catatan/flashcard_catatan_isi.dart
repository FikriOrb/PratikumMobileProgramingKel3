import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../user_data.dart';

class FlashcardCatatanIsiPage extends StatefulWidget {
  final String deckId; // Terima ID

  const FlashcardCatatanIsiPage({super.key, required this.deckId});

  @override
  State<FlashcardCatatanIsiPage> createState() => _FlashcardCatatanIsiPageState();
}

class _FlashcardCatatanIsiPageState extends State<FlashcardCatatanIsiPage> {
  final PageController _pageController = PageController();
  double _currentPageValue = 0.0;

  final Color bgDark = const Color(0xFF101922);
  final Color bgCard = const Color(0xFF1F2937);
  final Color textGray = const Color(0xFF9CA3AF);
  final Color primaryBlue = const Color(0xFF137FEC);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page!;
      });
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

  // --- CRUD (Ke UserData) ---
  void _tambahCatatan() { _showEditDialog(); }

  void _simpanCatatan(String teks, int? index) {
    if (index != null) {
      context.read<UserData>().editCardInDeck(widget.deckId, index, teks);
    } else {
      context.read<UserData>().addCardToDeck(widget.deckId, teks);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Ambil data terbaru untuk jump ke akhir
        var deck = context.read<UserData>().getDeckById(widget.deckId);
        var cards = deck['cards'] as List<String>;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(cards.length - 1);
        }
      });
    }
  }

  void _hapusCatatan(int index) {
    context.read<UserData>().deleteCardFromDeck(widget.deckId, index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var deck = context.read<UserData>().getDeckById(widget.deckId);
      var cards = deck['cards'] as List<String>;
      if (_pageController.hasClients && cards.isNotEmpty) {
        if (_pageController.page! >= cards.length) {
          _pageController.jumpToPage(cards.length - 1);
        }
      }
    });
  }

  void _showEditDialog({int? index}) {
    // Ambil teks saat ini jika edit
    String textAwal = "";
    if (index != null) {
      var deck = context.read<UserData>().getDeckById(widget.deckId);
      var cards = deck['cards'] as List<String>;
      textAwal = cards[index];
    }

    bool isEdit = index != null;
    TextEditingController controller = TextEditingController(text: textAwal);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? "Edit Catatan" : "Tambah Halaman Baru", style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  autofocus: true, maxLines: 8,
                  decoration: InputDecoration(
                    hintText: "Tulis isi catatan di sini...",
                    hintStyle: TextStyle(color: textGray),
                    filled: true, fillColor: Colors.black.withOpacity(0.2),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isEdit)
                      IconButton(onPressed: () { _hapusCatatan(index); Navigator.pop(context); }, icon: const Icon(Icons.delete, color: Colors.redAccent))
                    else const SizedBox(),
                    Row(
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: textGray))),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () {
                            if (controller.text.trim().isNotEmpty) {
                              _simpanCatatan(controller.text, index);
                              Navigator.pop(context);
                            }
                          },
                          child: Text("Simpan", style: GoogleFonts.lexend(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
      builder: (context, userData, child) {
        var deck = userData.getDeckById(widget.deckId);
        if (deck.isEmpty) return const Scaffold(body: Center(child: Text("Topik tidak ditemukan")));

        String judulTopik = deck['title'];
        List<String> daftarCatatan = List<String>.from(deck['cards']);
        double progressValue = daftarCatatan.isEmpty ? 0 : (_currentPageValue.round() + 1) / daftarCatatan.length;

        // Helper Navigasi
        void nextPage() {
          if (daftarCatatan.isNotEmpty && _currentPageValue < daftarCatatan.length - 1) {
            _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
          }
        }
        void prevPage() {
          if (daftarCatatan.isNotEmpty && _currentPageValue > 0) {
            _pageController.previousPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
          }
        }

        return Scaffold(
          backgroundColor: bgDark,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: FloatingActionButton(onPressed: _tambahCatatan, backgroundColor: primaryBlue, child: const Icon(Icons.add, color: Colors.white)),
          ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.white))),
                          Expanded(child: Text(judulTopik, textAlign: TextAlign.center, style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                    // PROGRESS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progressValue, backgroundColor: Colors.white.withOpacity(0.1), color: primaryBlue, minHeight: 6)),
                          const SizedBox(height: 8),
                          Text(daftarCatatan.isEmpty ? "0/0" : "${_currentPageValue.round() + 1}/${daftarCatatan.length}", style: GoogleFonts.lexend(color: textGray, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // KONTEN
                    Expanded(
                      child: daftarCatatan.isEmpty
                          ? _buildEmptyState()
                          : PageView.builder(
                              scrollDirection: Axis.vertical,
                              controller: _pageController,
                              itemCount: daftarCatatan.length,
                              itemBuilder: (context, index) {
                                return _buildFlipAnimation(index, _buildCardContent(index, daftarCatatan[index]));
                              },
                            ),
                    ),
                    // NAVIGASI
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(onPressed: (daftarCatatan.isNotEmpty && _currentPageValue.round() > 0) ? prevPage : null, icon: Icon(Icons.keyboard_arrow_up, color: (daftarCatatan.isNotEmpty && _currentPageValue.round() > 0) ? Colors.white : Colors.white24), iconSize: 36),
                          Container(width: 50, height: 50, decoration: BoxDecoration(color: primaryBlue.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.description, color: Colors.white, size: 24)),
                          IconButton(onPressed: (daftarCatatan.isNotEmpty && _currentPageValue.round() < daftarCatatan.length - 1) ? nextPage : null, icon: Icon(Icons.keyboard_arrow_down, color: (daftarCatatan.isNotEmpty && _currentPageValue.round() < daftarCatatan.length - 1) ? Colors.white : Colors.white24), iconSize: 36),
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

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.vertical_split, size: 64, color: textGray.withOpacity(0.3)), const SizedBox(height: 16), Text("Belum ada halaman.", style: GoogleFonts.lexend(color: textGray, fontSize: 16)), const SizedBox(height: 8), Text("Tekan tombol + untuk menambah halaman.", style: GoogleFonts.lexend(color: textGray.withOpacity(0.5), fontSize: 12))]));
  }

  Widget _buildCardContent(int index, String textIsi) {
    return Consumer<UserData>(
      builder: (context, userData, child) {
        var skin = userData.activeSkin;
        return Container(
          width: double.infinity, margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(color: skin['color'], borderRadius: BorderRadius.circular(24), border: Border.all(color: skin['border'], width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
                  child: Center(child: Text(textIsi, textAlign: TextAlign.center, style: GoogleFonts.lexend(color: skin['textColor'], fontSize: 20, fontWeight: FontWeight.bold, height: 1.5))),
                ),
              ),
              Positioned(top: 16, right: 16, child: InkWell(onTap: () => _showEditDialog(index: index), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.edit, color: skin['textColor'].withOpacity(0.7), size: 18)))),
            ],
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