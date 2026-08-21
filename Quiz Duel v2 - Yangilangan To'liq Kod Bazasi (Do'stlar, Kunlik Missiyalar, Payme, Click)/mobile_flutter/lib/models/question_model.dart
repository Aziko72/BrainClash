class QuestionModel {
  final int id;
  final String text;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String? correctOption;
  final String? explanation;

  QuestionModel({
    required this.id,
    required this.text,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    this.correctOption,
    this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? 0,
      text: json['text'] ?? json['question_text'] ?? '',
      optionA: json['option_a'] ?? '',
      optionB: json['option_b'] ?? '',
      optionC: json['option_c'] ?? '',
      optionD: json['option_d'] ?? '',
      correctOption: json['correct_option'],
      explanation: json['explanation'],
    );
  }
}
