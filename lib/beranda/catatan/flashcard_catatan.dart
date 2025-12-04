import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../user_data.dart';

// Import Halaman Tujuan
import 'flashcard_catatan_isi.dart';
import 'flashcard_review.dart';
import 'flashcard_autoplay.dart';

class FlashcardCatatanPage extends StatefulWidget {
  const FlashcardCatatanPage({super.key});

  @override
  State<FlashcardCatatanPage> createState() => _FlashcardCatatanPageState();
}

class _FlashcardCatatanPageState extends State<FlashcardCatatanPage> {
  final Color bgDark = const Color(0xFF101922);
  final Color bgCard = const Color(0xFF1F2937);
  final Color textGray = const Color(0xFF9CA3AF);
  final Color primaryBlue = const Color(0xFF137FEC);

  // --- FUNGSI SKIN SELECTOR ---
  void _showSkinSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Consumer<UserData>(
          builder: (context, userData, child) {
            var mySkins = userData.skins.where((s) => s['isOwned']).toList();
            return Container(
              padding: const EdgeInsets.all(24),
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Icon(Icons.drag_handle, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Text("Pilih Tema Kartu", style: GoogleFonts.lexend(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Tema ini akan dipakai saat belajar.", style: GoogleFonts.lexend(color: textGray, fontSize: 12)),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: mySkins.length,
                      itemBuilder: (context, index) {
                        var skin = mySkins[index];
                        bool isEquipped = skin['isEquipped'];
                        return GestureDetector(
                          onTap: () {
                            userData.equipSkin(skin['id']);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: skin['color'],
                              border: Border.all(color: isEquipped ? Colors.greenAccent : Colors.transparent, width: 3),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [if(isEquipped) BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 8)]
                            ),
                            child: Center(
                              child: isEquipped
                                ? const Icon(Icons.check_circle, color: Colors.green, size: 32)
                                : Text(skin['name'], textAlign: TextAlign.center, style: GoogleFonts.lexend(color: skin['id'] == 'dark' ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          },
        );
      }
    );
  }

  // --- CRUD TOPIC (DECK) ---
  void _showFormDialog({String? id, String? currentTitle}) {
    bool isEdit = id != null;
    TextEditingController controller = TextEditingController(text: currentTitle ?? "");

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
                Text(isEdit ? "Edit Topik" : "Topik Baru", style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Contoh: Biologi Bab 1...",
                    hintStyle: TextStyle(color: textGray),
                    filled: true, fillColor: Colors.black.withOpacity(0.2),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: textGray))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          if (isEdit) {
                            context.read<UserData>().editDeckTitle(id, controller.text);
                          } else {
                            context.read<UserData>().addDeck(controller.text);
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text("Simpan", style: GoogleFonts.lexend(color: Colors.white)),
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

  void _showDeleteConfirm(String id, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgCard,
        title: Text("Hapus Topik?", style: GoogleFonts.lexend(color: Colors.white)),
        content: Text("Kamu yakin ingin menghapus '$title'?\nSemua kartu di dalamnya akan hilang.", style: TextStyle(color: textGray)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: textGray))),
          TextButton(onPressed: () {
            context.read<UserData>().deleteDeck(id);
            Navigator.pop(context);
          }, child: const Text("Hapus", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  // --- DIALOG MENU ---
  void _showOptionsDialog(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text("Pilih Aksi: $title", style: GoogleFonts.lexend(fontSize: 14, color: textGray, fontWeight: FontWeight.w500))),
                const SizedBox(height: 24),
                _buildOptionTile(
                  icon: Icons.play_arrow_rounded, iconBgColor: primaryBlue, iconColor: Colors.white,
                  title: "Pelajari / Edit Isi", subtitle: "Tambah atau baca kartu",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardCatatanIsiPage(deckId: id)));
                  },
                ),
                const SizedBox(height: 8),
                _buildOptionTile(
                  icon: Icons.style_rounded, iconBgColor: Colors.white10, iconColor: Colors.white,
                  title: "Ulangi Catatan", subtitle: "Review catatanmu",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardReviewPage(deckId: id)));
                  }
                ),
                const SizedBox(height: 8),
                _buildOptionTile(
                  icon: Icons.smart_display_rounded, iconBgColor: Colors.white10, iconColor: Colors.white,
                  title: "Autoplay", subtitle: "Lihat kartu otomatis",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardAutoplayPage(deckId: id)));
                  }
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, child: TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: GoogleFonts.lexend(color: textGray)))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({required IconData icon, required Color iconBgColor, required Color iconColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 28)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), Text(subtitle, style: GoogleFonts.lexend(fontSize: 13, color: textGray))])), Icon(Icons.chevron_right, color: textGray.withOpacity(0.5))])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: GridPainter())),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(20), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.white))),
                      const SizedBox(width: 16),
                      Expanded(child: Text("Flash Card: Topik", style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                      InkWell(onTap: () => _showSkinSelector(context), borderRadius: BorderRadius.circular(20), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle), child: const Icon(Icons.palette, color: Colors.pinkAccent))),
                      const SizedBox(width: 12),
                      InkWell(onTap: () => _showFormDialog(), borderRadius: BorderRadius.circular(20), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: primaryBlue, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white))),
                    ],
                  ),
                ),

                Expanded(
                  child: Consumer<UserData>(
                    builder: (context, userData, child) {
                      var decks = userData.flashcardDecks;
                      if (decks.isEmpty) {
                        return Center(child: Text("Belum ada topik.\nTekan + untuk membuat.", textAlign: TextAlign.center, style: TextStyle(color: textGray)));
                      }
                      
                      // REORDERABLE LIST VIEW
                      return ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        // Logika Reorder dari UserData
                        onReorder: (oldIndex, newIndex) => userData.reorderDecks(oldIndex, newIndex),
                        itemCount: decks.length,
                        itemBuilder: (context, index) {
                          var deck = decks[index];
                          // Kirim INDEX ke buildListItem
                          return _buildListItem(context, index, deck['id'], deck['title']);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ITEM LIST (UPDATED: Tambah Index & Listener) ---
  Widget _buildListItem(BuildContext context, int index, String id, String title) {
    return Container(
      key: ValueKey(id), // Key Wajib untuk ReorderableListView
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          // 1. DRAG HANDLE (PENGGESER)
          // Ini adalah widget ajaib yang mengaktifkan fitur geser
          ReorderableDragStartListener(
            index: index,
            child: Container(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 8),
              color: Colors.transparent, // Area sentuh
              child: Icon(Icons.drag_indicator, color: textGray),
            ),
          ),
          
          // 2. KONTEN (JUDUL) -> BISA DIKLIK MASUK
          Expanded(
            child: InkWell(
              onTap: () => _showOptionsDialog(context, id, title),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Text(title, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ),
          ),

          // 3. TOMBOL AKSI (EDIT & HAPUS)
          InkWell(onTap: () => _showFormDialog(id: id, currentTitle: title), child: Padding(padding: const EdgeInsets.all(12.0), child: Icon(Icons.edit, size: 20, color: textGray))),
          InkWell(onTap: () => _showDeleteConfirm(id, title), child: Padding(padding: const EdgeInsets.only(left: 4, right: 16, top: 12, bottom: 12), child: Icon(Icons.delete, size: 20, color: textGray))),
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