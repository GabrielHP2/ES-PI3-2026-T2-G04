import 'package:cloud_firestore/cloud_firestore.dart';

enum QuestionStatus { active, deleted, reported }

class Question {
  String? answerText;
  Timestamp? answeredAt;
  String? answeredById;
  String? answeredByName;
  Timestamp createdAt;
  bool isAnswered;
  bool isPublic;
  String questionText;
  String startupId;
  QuestionStatus status;
  String userId;
  String userName;

  Question({
    required this.createdAt,
    this.answeredAt,
    this.answerText,
    this.answeredByName,
    required this.isAnswered,
    this.answeredById,
    required this.isPublic,
    required this.questionText,
    required this.startupId,
    required this.status,
    required this.userId,
    required this.userName,
  });
}
