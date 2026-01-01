class QuizQuestion {
  final String question;
  final List options;
  final String correctAnswer;

  const QuizQuestion(this.question, this.options, this.correctAnswer);

  factory QuizQuestion.fromFirestore(Map<String, dynamic> data) {
    return QuizQuestion(
      data['pertanyaan'] ?? '',
      List<String>.from(data['pilihan'] ?? []),
      data['jawaban'] ?? '',
    );
  }
}
