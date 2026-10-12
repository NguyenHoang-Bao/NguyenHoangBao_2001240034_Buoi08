import 'package:flutter/material.dart';
import '../../models/vocabulary.dart';
import '../../services/notification_service.dart';
import '../../services/vocab_service.dart';

class ScreenVocabLearn extends StatefulWidget {
  const ScreenVocabLearn({super.key});

  @override
  State<ScreenVocabLearn> createState() => _ScreenVocabLearnState();
}

class _ScreenVocabLearnState extends State<ScreenVocabLearn> {
  final TextEditingController answerController = TextEditingController();
  final VocabService vocabService = VocabService();
  final NotificationService notiService = NotificationService();

  List<Vocabulary> vocabList = [];
  int currentIndex = 0;
  int correctCount = 0;
  int wrongCount = 0;
  String? feedbackMessage;
  bool? isLastAnswerCorrect;

  @override
  void initState() {
    super.initState();
    notiService.init();
    loadWords();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  void loadWords() async {
    final list = await vocabService.loadVocabularies();
    setState(() {
      vocabList = list;
    });
  }

  // Xử lý kiểm tra đáp án
  void checkAnswer() async {
    if (vocabList.isEmpty) return;

    final userInput = answerController.text.trim().toLowerCase();
    if (userInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập nghĩa tiếng Việt!"),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final currentVocab = vocabList[currentIndex];
    final correctMeaning = currentVocab.meaning.trim().toLowerCase();

    // So sánh (chấp nhận khớp toàn bộ hoặc chứa từ khóa chính)
    final isCorrect = userInput == correctMeaning ||
        correctMeaning.split(RegExp(r'[/,;]')).any((element) => element.trim() == userInput);

    if (isCorrect) {
      correctCount++;
      feedbackMessage = "Chính xác! '$userInput' là nghĩa đúng.";
      isLastAnswerCorrect = true;
    } else {
      wrongCount++;
      feedbackMessage = "Chưa đúng! Nghĩa đúng của '${currentVocab.word}' là: '${currentVocab.meaning}'";
      isLastAnswerCorrect = false;

      // Yêu cầu quan trọng của đề bài:
      // "Nếu số từ sai là bội số của 3 sẽ hiển thị một notification."
      if (wrongCount % 3 == 0) {
        await notiService.showSimpleNotification(
          id: 3000 + wrongCount,
          title: "Cảnh báo ôn tập từ vựng",
          body: "Bạn đã trả lời sai $wrongCount từ! Hãy chú ý ôn lại kỹ hơn nhé.",
        );
      }
    }

    answerController.clear();

    // Chuyển sang từ kế tiếp
    if (currentIndex < vocabList.length - 1) {
      currentIndex++;
    } else {
      // Đã đi hết danh sách, quay lại từ đầu (đảo ngẫu nhiên)
      vocabList.shuffle();
      currentIndex = 0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentWord =
        vocabList.isNotEmpty ? vocabList[currentIndex].word : "Đang tải...";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ôn tập từ mới"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // 2 ô thông báo trạng thái phía trên theo đúng hình ảnh trong PDF (trang 23)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ô Đúng: Xanh lá
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        "$correctCount từ",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Ô Sai: Màu cam
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.close, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        "$wrongCount từ",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Khung hiển thị từ tiếng Anh
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Center(
                child: Text(
                  currentWord,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ô nhập nghĩa tiếng Việt
            TextField(
              controller: answerController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Nhập nghĩa tiếng Việt",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              onSubmitted: (_) => checkAnswer(),
            ),
            const SizedBox(height: 20),

            // Nút Check
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Check",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Thông báo kết quả phản hồi của câu trả lời trước đó
            if (feedbackMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLastAnswerCorrect == true
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isLastAnswerCorrect == true
                        ? Colors.green.shade300
                        : Colors.red.shade300,
                  ),
                ),
                child: Text(
                  feedbackMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isLastAnswerCorrect == true
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),

            const SizedBox(height: 20),
            Text(
              "Lưu ý: Cứ trả lời sai bội số của 3 từ (3, 6, 9,...) hệ thống sẽ tự động phát một Notification cảnh báo!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
