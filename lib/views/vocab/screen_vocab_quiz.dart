import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/vocab_service.dart';

class QuizQuestion {
  final String word;
  final String displayedMeaning;
  final bool isActuallyCorrect;

  QuizQuestion({
    required this.word,
    required this.displayedMeaning,
    required this.isActuallyCorrect,
  });
}

class ScreenVocabQuiz extends StatefulWidget {
  const ScreenVocabQuiz({super.key});

  @override
  State<ScreenVocabQuiz> createState() => _ScreenVocabQuizState();
}

class _ScreenVocabQuizState extends State<ScreenVocabQuiz> {
  final VocabService vocabService = VocabService();

  List<QuizQuestion> questions = [];
  int currentIndex = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    generateQuizQuestions();
  }

  void generateQuizQuestions() async {
    final vocabList = await vocabService.loadVocabularies();
    if (vocabList.isEmpty) return;

    final random = Random();
    final List<QuizQuestion> generated = [];

    // Tạo bộ câu hỏi (10 câu hoặc theo số lượng từ vựng)
    final totalCount = vocabList.length < 5 ? vocabList.length * 2 : vocabList.length;

    for (int i = 0; i < totalCount; i++) {
      final target = vocabList[i % vocabList.length];
      final bool shouldBeCorrect = random.nextBool();

      String meaningToDisplay;
      if (shouldBeCorrect || vocabList.length == 1) {
        meaningToDisplay = target.meaning;
      } else {
        // Lấy nghĩa của một từ khác ngẫu nhiên để tạo câu hỏi sai
        final otherVocab = vocabList.where((v) => v.word != target.word).toList();
        final randomOther = otherVocab[random.nextInt(otherVocab.length)];
        meaningToDisplay = randomOther.meaning;
      }

      generated.add(QuizQuestion(
        word: target.word,
        displayedMeaning: meaningToDisplay,
        isActuallyCorrect: shouldBeCorrect,
      ));
    }

    generated.shuffle();

    setState(() {
      questions = generated;
      currentIndex = 0;
      correctAnswers = 0;
      wrongAnswers = 0;
      isFinished = false;
    });
  }

  void handleUserChoice(bool userChosenCorrect) {
    if (questions.isEmpty || isFinished) return;

    final currentQuestion = questions[currentIndex];
    final bool isUserRight = (userChosenCorrect == currentQuestion.isActuallyCorrect);

    if (isUserRight) {
      correctAnswers++;
    } else {
      wrongAnswers++;
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      setState(() {
        isFinished = true;
      });
      showResultDialog();
    }
  }

  // Hộp thoại MessageBox hiển thị kết quả kiểm tra theo đúng hình mẫu PDF (trang 24)
  void showResultDialog() {
    final total = correctAnswers + wrongAnswers;
    final double percentage = total > 0 ? (correctAnswers / total) * 100 : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Center(
            child: Text(
              "Kết thúc bài kiểm tra",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Tổng số câu: $total",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 6),
                  Text("Đúng: $correctAnswers", style: const TextStyle(fontSize: 15)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cancel, color: Colors.red, size: 20),
                  const SizedBox(width: 6),
                  Text("Sai: $wrongAnswers", style: const TextStyle(fontSize: 15)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Tỉ lệ chính xác: ${percentage.toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 50 ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                generateQuizQuestions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Làm lại"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Trở về trang chính
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Thoát"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Trắc nghiệm Đúng / Sai"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trắc nghiệm Đúng / Sai"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // Ô đếm số câu đúng / sai ở trên
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Đúng: $correctAnswers",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Sai: $wrongAnswers",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Câu ${currentIndex + 1} / ${questions.length}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 30),

            // Card hiển thị câu hỏi và đáp án
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentQuestion.word,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentQuestion.displayedMeaning,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 2 Nút: "✔ Đúng" và "✖ Sai" theo hình mẫu PDF (trang 24)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => handleUserChoice(true),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      "Đúng",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => handleUserChoice(false),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      "Sai",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
