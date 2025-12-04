import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../user_data.dart';
import 'flashcard_qna_play.dart';
import 'flashcard_qna_edit.dart';

class FlashcardQnAPage extends StatefulWidget {
  const FlashcardQnAPage({super.key});

  @override
  State<FlashcardQnAPage> createState() => _FlashcardQnAPageState();
}

class _FlashcardQnAPageState extends State<FlashcardQnAPage> {
  final Color bgDark = const Color(0xFF101922);
  final Color bgCard = const Color(0xFF1F2937);
  final Color textGray = const Color(0xFF9CA3AF);
  final Color primaryTeal = const Color(0xFF14B8A6);

  // --- DIALOG FORM (TAMBAH & EDIT JUDUL) ---
  void _showFormDialog(BuildContext context, {String? id, String? currentTitle}) {
    bool isEdit = id != null;
    TextEditingController controller = TextEditingController(text: currentTitle ?? "");

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
              Text(isEdit ? "Ganti Nama Kuis" : "Buat Kuis Baru", style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Judul Kuis...",
                  hintStyle: TextStyle(color: textGray),
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
                      if (controller.text.isNotEmpty) {
                        if (isEdit) {
                          context.read<UserData>().editQuizTitle(id, controller.text);
                        } else {
                          context.read<UserData>().addQuiz(controller.text);
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
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, String id, String title) {
    showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: bgCard, title: Text("Hapus Kuis?", style: GoogleFonts.lexend(color: Colors.white)), content: Text("Hapus '$title'? Data hilang permanen.", style: TextStyle(color: textGray)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: TextStyle(color: textGray))), TextButton(onPressed: () { context.read<UserData>().deleteQuiz(id); Navigator.pop(context); }, child: const Text("Hapus", style: TextStyle(color: Colors.redAccent)))]));
  }

  void _showOptionsDialog(BuildContext context, String id, String title, List<Map<String, String>> questions) {
    showDialog(context: context, builder: (context) { return Dialog(backgroundColor: Colors.transparent, insetPadding: const EdgeInsets.all(20), child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))]), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Center(child: Text("Pilih Aksi", style: GoogleFonts.lexend(fontSize: 14, color: textGray, fontWeight: FontWeight.w500))), const SizedBox(height: 24), 
      
      _buildOptionTile(
        icon: Icons.play_circle_fill, iconBgColor: primaryTeal, iconColor: Colors.white, 
        title: "Mulai Kuis", subtitle: "Uji pengetahuanmu", 
        onTap: () { 
          Navigator.pop(context); 
          if (questions.length < 2) { 
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tambahkan minimal 2 soal dulu ya!"))); return; 
          } 
          Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardQnAPlayPage(quizId: id))); // KIRIM ID
        }
      ), 
      
      const SizedBox(height: 8), 
      
      _buildOptionTile(
        icon: Icons.edit_note, iconBgColor: Colors.white10, iconColor: Colors.white, 
        title: "Edit Pertanyaan", subtitle: "Tambah/Hapus soal kuis", 
        onTap: () { 
          Navigator.pop(context); 
          Navigator.push(context, MaterialPageRoute(builder: (context) => FlashcardQnAEditPage(quizId: id))); // KIRIM ID
        }
      ), 
      
      const SizedBox(height: 16), SizedBox(width: double.infinity, child: TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: GoogleFonts.lexend(color: textGray))))]))); });
  }

  void _showSkinSelector(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: bgCard, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (context) { return Consumer<UserData>(builder: (context, userData, child) { var mySkins = userData.skins.where((s) => s['isOwned']).toList(); return Container(padding: const EdgeInsets.all(24), height: 300, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Center(child: Icon(Icons.drag_handle, color: Colors.grey)), const SizedBox(height: 16), Text("Pilih Tema Kartu", style: GoogleFonts.lexend(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 24), Expanded(child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: mySkins.length, itemBuilder: (context, index) { var skin = mySkins[index]; bool isEquipped = skin['isEquipped']; return GestureDetector(onTap: () { userData.equipSkin(skin['id']); Navigator.pop(context); }, child: Container(width: 100, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: skin['color'], border: Border.all(color: isEquipped ? Colors.greenAccent : Colors.transparent, width: 3), borderRadius: BorderRadius.circular(12), boxShadow: [if(isEquipped) BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 8)]), child: Center(child: isEquipped ? const Icon(Icons.check_circle, color: Colors.green, size: 32) : Text(skin['name'], textAlign: TextAlign.center, style: GoogleFonts.lexend(color: skin['id']=='dark'?Colors.white:Colors.black, fontWeight: FontWeight.bold, fontSize: 12))))); }))])); }); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: GridPainter())),
          SafeArea(
            child: Column(children: [
              Padding(padding: const EdgeInsets.all(16.0), child: Row(children: [InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(20), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.arrow_back, color: Colors.white))), const SizedBox(width: 16), Expanded(child: Text("Flash Card: QnA", style: GoogleFonts.lexend(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))), InkWell(onTap: () => _showSkinSelector(context), borderRadius: BorderRadius.circular(20), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle), child: const Icon(Icons.palette, color: Colors.pinkAccent))), const SizedBox(width: 12), InkWell(onTap: () => _showFormDialog(context), borderRadius: BorderRadius.circular(20), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: primaryTeal, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white)))])) , 
              
              // CONSUMER USER DATA
              Expanded(
                child: Consumer<UserData>(
                  builder: (context, userData, child) {
                    var quizzes = userData.quizzes;
                    if (quizzes.isEmpty) return Center(child: Text("Belum ada kuis.\nTekan + untuk membuat.", textAlign: TextAlign.center, style: TextStyle(color: textGray)));
                    
                    return ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16), 
                      onReorder: (oldIndex, newIndex) => userData.reorderQuizzes(oldIndex, newIndex), 
                      itemCount: quizzes.length, 
                      itemBuilder: (context, index) { 
                        var quiz = quizzes[index];
                        // Konversi dynamic list ke List<Map<String, String>>
                        List<Map<String, String>> questions = [];
                        if (quiz['questions'] != null) {
                           for (var q in quiz['questions']) {
                             questions.add(Map<String, String>.from(q));
                           }
                        }
                        
                        return _buildListItem(context, index, quiz['id'], quiz['title'], questions); 
                      }
                    );
                  }
                )
              )
            ])
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, int index, String id, String title, List<Map<String, String>> questions) {
    int jumlahSoal = questions.length;
    return Container(
      key: ValueKey(id), // Key Wajib
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          // Drag Handle
          ReorderableDragStartListener(index: index, child: Container(padding: const EdgeInsets.all(16), color: Colors.transparent, child: Icon(Icons.drag_indicator, color: textGray))),
          
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryTeal.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.quiz, color: primaryTeal, size: 18)),
          const SizedBox(width: 12),
          
          Expanded(
            child: InkWell(
              onTap: () => _showOptionsDialog(context, id, title, questions),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)), Text("$jumlahSoal Pertanyaan", style: GoogleFonts.lexend(fontSize: 12, color: textGray))]),
              ),
            ),
          ),
          
          // Tombol Edit
          InkWell(onTap: () => _showFormDialog(context, id: id, currentTitle: title), child: Padding(padding: const EdgeInsets.all(12.0), child: Icon(Icons.edit, size: 20, color: textGray))),
          // Tombol Hapus
          InkWell(onTap: () => _showDeleteConfirm(context, id, title), child: Padding(padding: const EdgeInsets.only(right: 16, left: 4, top: 12, bottom: 12), child: Icon(Icons.delete, size: 20, color: textGray))),
        ],
      ),
    );
  }
  
  Widget _buildOptionTile({required IconData icon, required Color iconBgColor, required Color iconColor, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 28)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)), Text(subtitle, style: GoogleFonts.lexend(fontSize: 13, color: textGray))])), Icon(Icons.chevron_right, color: textGray.withOpacity(0.5))])));
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