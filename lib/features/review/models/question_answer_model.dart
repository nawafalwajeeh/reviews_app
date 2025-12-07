// models/question_answer_model.dart
import '../../../utils/constants/enums.dart';

class QuestionAnswer {
  final String questionId;
  final String question;
  final QuestionType type;
  final dynamic answer; // Can be double (rating), bool (yes/no), or String (text)

  QuestionAnswer({
    required this.questionId,
    required this.question,
    required this.type,
    required this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'question': question,
      'type': type.toString().split('.').last,
      'answer': answer,
    };
  }

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    // Handle different answer types
    dynamic answerValue;
    final typeString = json['type']?.toString() ?? 'text';
    final questionType = QuestionType.values.firstWhere(
      (e) => e.toString().split('.').last == typeString,
      orElse: () => QuestionType.text,
    );

    switch (questionType) {
      case QuestionType.rating:
        answerValue = (json['answer'] as num?)?.toDouble() ?? 0.0;
        break;
      case QuestionType.yesOrNo:
        answerValue = json['answer'] as bool? ?? false;
        break;
      case QuestionType.text:
        answerValue = json['answer']?.toString() ?? '';
        break;
    }

    return QuestionAnswer(
      questionId: json['questionId']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      type: questionType,
      answer: answerValue,
    );
  }
}

