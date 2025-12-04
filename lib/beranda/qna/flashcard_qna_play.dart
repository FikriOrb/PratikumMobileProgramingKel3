import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../user_data.dart';

class FlashcardQnAPlayPage extends StatefulWidget {
  final String quizId; // Terima ID

  const FlashcardQnAPlayPage({super.key, required this.quizId});

  @override
  State<FlashcardQnAPlayPage> createState() => _FlashcardQnAPlayPageState();
}

class _FlashcardQnAPlayPageState extends State<FlashcardQnAPlayPage> with SingleTickerProviderStateMixin {
  List<Map<String, String>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  List<String> _currentOptions = []; 
  String _selectedOption = ""; 

  late AnimationController _controller;
  late Animation<double> _animation;

  final Color bgDark = const Color(0xFF101922);
  final Color primaryTeal = const Color(0xFF14B8A6);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    
    // Load data setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  void _loadData() {
    var quiz = context.read<UserData>().getQuizById(widget.quizId);
    if (quiz.isNotEmpty && quiz['questions'] != null) {
      List<Map<String, String>> rawData = [];
      for (var item in quiz['questions']) rawData.add(Map<String, String>.from(item));
      
      setState(() {
        _questions = rawData;
        _questions.shuffle(); // Acak urutan soal
        _generateOptions();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateOptions() {
    if (_questions.isEmpty) return;
    
    String correctAnswer = _questions[_currentIndex]['a']!;
    
    // Ambil jawaban salah dari soal lain dalam kuis yang sama
    List<String> wrongAnswers = _questions
        .where((q) => q['a'] != correctAnswer)
        .map((q) => q['a']!)
        .toList();
        
    // Jika jumlah soal sedikit (< 4), kita butuh dummy distractor agar pilihan ganda tetap ada
    if (wrongAnswers.length < 3) {
      // Tambahkan dummy answers jika soal kurang dari 4
      wrongAnswers.addAll(["A", "B", "C", "D"]); 
    }

    wrongAnswers.shuffle();
    int maxWrong = min(3, wrongAnswers.length);
    List<String> options = wrongAnswers.take(maxWrong).toList();
    options.add(correctAnswer);
    options.shuffle();
    
    setState(() { _currentOptions = options; _isAnswered = false; _selectedOption = ""; });
  }

  void _flipCard() {
    if (_controller.isCompleted) _controller.reverse(); else _controller.forward();
  }

  void _handleAnswer(String selectedAnswer) {
    if (_isAnswered) return;
    String correctAnswer = _questions[_currentIndex]['a']!;
    bool isCorrect = (selectedAnswer == correctAnswer);

    setState(() {
      _isAnswered = true;
      _selectedOption = selectedAnswer;
      if (isCorrect) {
         _score++;
         context.read<UserData>().incrementQnACorrect();
      }
    });
    
    _flipCard(); // Balik kartu otomatis

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (_currentIndex < _questions.length - 1) {
        setState(() { _currentIndex++; _controller.reset(); });
        _generateOptions(); 
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (context) => AlertDialog(backgroundColor: const Color(0xFF1F2937), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Center(child: Text("Hasil Kuis", style: GoogleFonts.lexend(color: Colors.white, fontWeight: FontWeight.bold))), content: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: primaryTeal.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.emoji_events, size: 48, color: primaryTeal)), const SizedBox(height: 16), Text("Skor Kamu", style: TextStyle(color: Colors.white70)), Text("$_score / ${_questions.length}", style: GoogleFonts.lexend(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white))]), actions: [Center(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text("Selesai", style: GoogleFonts.lexend(color: Colors.white))))) ]));
  }
  
  Color _getButtonColor(String option) { if (!_isAnswered) return const Color(0xFF1F2937); String correctAnswer = _questions[_currentIndex]['a']!; if (option == correctAnswer) return Colors.green.withOpacity(0.8); if (option == _selectedOption && option != correctAnswer) return Colors.red.withOpacity(0.8); return const Color(0xFF1F2937).withOpacity(0.5); }

  @override
  Widget build(BuildContext context) {
    // Handling Loading State atau jika soal kosong
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: bgDark,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(child: Text("Memuat Soal...", style: TextStyle(color: Colors.white)))
      );
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
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [InkWell(onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white))), Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (_currentIndex + 1) / _questions.length, backgroundColor: Colors.white10, color: primaryTeal, minHeight: 8)))), Text("${_currentIndex + 1}/${_questions.length}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])),
                const SizedBox(height: 20),

                // --- KARTU SOAL DENGAN SKIN (CONSUMER) ---
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Consumer<UserData>(
                      builder: (context, userData, child) {
                        return GestureDetector(
                          onTap: _flipCard,
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              final angle = _animation.value * pi;
                              final isBack = angle >= pi / 2;
                              final transform = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle);
                              
                              return Transform(
                                transform: transform,
                                alignment: Alignment.center,
                                child: isBack 
                                    ? Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(pi), child: _buildCardFace(userData, false)) 
                                    : _buildCardFace(userData, true),
                              );
                            },
                          ),
                        );
                      }
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Pilihan Jawaban
                Expanded(
                  flex: 3,
                  child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(children: _currentOptions.map((option) { return Padding(padding: const EdgeInsets.only(bottom: 12), child: InkWell(onTap: () => _handleAnswer(option), borderRadius: BorderRadius.circular(16), child: AnimatedContainer(duration: const Duration(milliseconds: 300), width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), decoration: BoxDecoration(color: _getButtonColor(option), borderRadius: BorderRadius.circular(16), border: Border.all(color: (_isAnswered && option == _questions[_currentIndex]['a']!) ? Colors.greenAccent : Colors.white10)), child: Row(children: [Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white30), color: Colors.transparent), child: _isAnswered && option == _questions[_currentIndex]['a']! ? const Icon(Icons.check, size: 16, color: Colors.greenAccent) : (_isAnswered && option == _selectedOption) ? const Icon(Icons.close, size: 16, color: Colors.white) : null), const SizedBox(width: 16), Expanded(child: Text(option, style: GoogleFonts.lexend(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)))])))); }).toList())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFace(UserData userData, bool isQuestion) {
    var skin = userData.activeSkin;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: skin['color'], 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: skin['border'], width: 2),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isQuestion ? "PERTANYAAN" : "JAWABAN", style: GoogleFonts.lexend(color: skin['textColor'].withOpacity(0.6), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Text(
                isQuestion ? _questions[_currentIndex]['q']! : _questions[_currentIndex]['a']!,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  color: skin['textColor'], 
                  fontSize: 24, fontWeight: FontWeight.w600, height: 1.4
                ),
              ),
            ],
          ),
        ),
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