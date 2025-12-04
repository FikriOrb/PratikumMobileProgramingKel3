import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; 
import '../../user_data.dart'; 

class FlashcardQnAEditPage extends StatefulWidget {
  final String quizId; // Terima ID Kuis

  const FlashcardQnAEditPage({super.key, required this.quizId});

  @override
  State<FlashcardQnAEditPage> createState() => _FlashcardQnAEditPageState();
}

class _FlashcardQnAEditPageState extends State<FlashcardQnAEditPage> {
  final Color bgDark = const Color(0xFF101922);
  final Color bgCard = const Color(0xFF1F2937);
  final Color textGray = const Color(0xFF9CA3AF);
  final Color primaryTeal = const Color(0xFF14B8A6);

  // --- HELPER WRAPPER KE USERDATA ---
  void _updateQuestions(List<Map<String, String>> newList) {
    context.read<UserData>().updateQuizQuestions(widget.quizId, newList);
  }

  // Helper untuk mengambil list terbaru dari provider sebelum dimodifikasi
  List<Map<String, String>> _getCurrentList() {
    var quiz = context.read<UserData>().getQuizById(widget.quizId);
    List<Map<String, String>> currentList = [];
    if (quiz['questions'] != null) {
      for (var item in quiz['questions']) currentList.add(Map<String, String>.from(item));
    }
    return currentList;
  }

  void _tambahSoal(String q, String a) {
    List<Map<String, String>> currentList = _getCurrentList();
    currentList.add({'q': q, 'a': a});
    _updateQuestions(currentList);
  }

  void _editSoal(int index, String q, String a) {
    List<Map<String, String>> currentList = _getCurrentList();
    currentList[index] = {'q': q, 'a': a};
    _updateQuestions(currentList);
  }

  void _hapusSoal(int index) {
    List<Map<String, String>> currentList = _getCurrentList();
    currentList.removeAt(index);
    _updateQuestions(currentList);
  }

  void _onReorder(int oldIndex, int newIndex) {
    List<Map<String, String>> currentList = _getCurrentList();
    if (oldIndex < newIndex) newIndex -= 1;
    final item = currentList.removeAt(oldIndex);
    currentList.insert(newIndex, item);
    _updateQuestions(currentList);
  }

  // --- DIALOG FORM ---
  void _showFormDialog({int? index, String? currentQ, String? currentA}) {
    bool isEdit = index != null;
    TextEditingController qCtrl = TextEditingController(text: currentQ ?? "");
    TextEditingController aCtrl = TextEditingController(text: currentA ?? "");

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEdit ? "Edit Soal" : "Tambah Soal", style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              
              Text("Pertanyaan (Q)", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: qCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Contoh: 1 + 1 = ?",
                  hintStyle: TextStyle(color: textGray.withOpacity(0.5)),
                  filled: true, fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Text("Jawaban (A)", style: TextStyle(color: textGray, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: aCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Contoh: 2",
                  hintStyle: TextStyle(color: textGray.withOpacity(0.5)),
                  filled: true, fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: textGray))),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryTeal),
                    onPressed: () {
                      if (qCtrl.text.isNotEmpty && aCtrl.text.isNotEmpty) {
                        isEdit 
                          ? _editSoal(index!, qCtrl.text, aCtrl.text)
                          : _tambahSoal(qCtrl.text, aCtrl.text);
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
      ),
    );
  }

  // --- DIALOG DELETE ---
  void _showDeleteConfirm(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgCard,
        title: Text("Hapus Soal?", style: GoogleFonts.lexend(color: Colors.white)),
        content: Text("Data tidak bisa dikembalikan.", style: TextStyle(color: textGray)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: textGray))),
          TextButton(onPressed: () { _hapusSoal(index); Navigator.pop(context); }, child: const Text("Hapus", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
      builder: (context, userData, child) {
        var quiz = userData.getQuizById(widget.quizId);
        if (quiz.isEmpty) return const Scaffold(body: Center(child: Text("Kuis tidak ditemukan")));
        
        String judulTopik = quiz['title'];
        List<Map<String, String>> daftarSoal = [];
        if (quiz['questions'] != null) {
          for (var item in quiz['questions']) daftarSoal.add(Map<String, String>.from(item));
        }

        return Scaffold(
          backgroundColor: bgDark,
          body: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: GridPainter())),
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.white)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Edit Pertanyaan", style: GoogleFonts.lexend(fontSize: 12, color: textGray)),
                                Text(judulTopik, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => _showFormDialog(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(width: 40, height: 40, decoration: BoxDecoration(color: primaryTeal, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),

                    // List Soal
                    Expanded(
                      child: daftarSoal.isEmpty
                          ? Center(child: Text("Belum ada soal.\nTekan + untuk menambah.", textAlign: TextAlign.center, style: TextStyle(color: textGray)))
                          : ReorderableListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              onReorder: _onReorder,
                              itemCount: daftarSoal.length,
                              itemBuilder: (context, index) {
                                return _buildListItem(context, index, daftarSoal[index]['q']!, daftarSoal[index]['a']!);
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
    );
  }

  Widget _buildListItem(BuildContext context, int index, String q, String a) {
    return Container(
      key: ValueKey("$q$a$index"), // Key Unik kombinasi
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableDragStartListener(index: index, child: Padding(padding: const EdgeInsets.only(top: 4), child: Icon(Icons.drag_indicator, color: textGray))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Text("Q: ", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)), Expanded(child: Text(q, style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.w500)))]),
                const SizedBox(height: 4),
                Row(children: [Text("A: ", style: TextStyle(color: textGray, fontWeight: FontWeight.bold)), Expanded(child: Text(a, style: GoogleFonts.lexend(color: textGray)))]),
              ],
            ),
          ),
          InkWell(onTap: () => _showFormDialog(index: index, currentQ: q, currentA: a), child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.edit, size: 20, color: textGray))),
          InkWell(onTap: () => _showDeleteConfirm(index), child: Padding(padding: const EdgeInsets.all(4), child: Icon(Icons.delete, size: 20, color: textGray))),
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