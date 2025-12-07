import '../../../utils/constants/enums.dart';

class CustomQuestion {
  final String id;
  final String question;
  final QuestionType type; // RATING, YES_NO, TEXT
  final bool isRequired;

  CustomQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.isRequired = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'type': type.toString().split('.').last,
      'isRequired': isRequired,
    };
  }

  factory CustomQuestion.fromJson(Map<String, dynamic> json) {
    return CustomQuestion(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      type: QuestionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => QuestionType.yesOrNo,
      ),
      isRequired: json['isRequired'] ?? false,
    );
  }
}
