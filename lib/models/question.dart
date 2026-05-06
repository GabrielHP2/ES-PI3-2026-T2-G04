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

  factory Question.fromMap(Map<String, dynamic> map) {
    // createdAt pode vir como Timestamp ou como um Map serializado
    dynamic created = map['createdAt'] ?? map['created_at'] ?? map['created'];
    Timestamp createdAtTs;
    if (created is Timestamp) {
      createdAtTs = created;
    } else if (created is Map && created.containsKey('_seconds')) {
      final seconds = created['_seconds'] as int;
      final nanos = created['_nanoseconds'] as int? ?? 0;
      createdAtTs = Timestamp(seconds, nanos);
    } else if (created is int) {
      createdAtTs = Timestamp.fromMillisecondsSinceEpoch(created);
    } else if (created is double) {
      createdAtTs = Timestamp.fromMillisecondsSinceEpoch(created.toInt());
    } else {
      // fallback para evitar null
      createdAtTs = Timestamp.now();
    }

    dynamic answered = map['answeredAt'] ?? map['answered_at'];
    Timestamp? answeredAtTs;
    if (answered is Timestamp) {
      answeredAtTs = answered;
    } else if (answered is Map && answered.containsKey('_seconds')) {
      final seconds = answered['_seconds'] as int;
      final nanos = answered['_nanoseconds'] as int? ?? 0;
      answeredAtTs = Timestamp(seconds, nanos);
    }

    QuestionStatus status = QuestionStatus.active;
    final statusRaw = map['status'] ?? map['question_status'];
    if (statusRaw is String) {
      switch (statusRaw) {
        case 'deleted':
          status = QuestionStatus.deleted;
          break;
        case 'reported':
          status = QuestionStatus.reported;
          break;
        default:
          status = QuestionStatus.active;
      }
    }

    return Question(
      createdAt: createdAtTs,
      answeredAt: answeredAtTs,
      answerText: map['answerText'] ?? map['answer_text'],
      answeredByName: map['answeredByName'] ?? map['answered_by_name'],
      isAnswered: map['isAnswered'] ?? map['is_answered'] ?? false,
      answeredById: map['answeredById'] ?? map['answered_by_id'],
      isPublic: map['isPublic'] ?? map['is_public'] ?? false,
      questionText: map['questionText'] ?? map['question_text'] ?? '',
      startupId: map['startupId'] ?? map['startup_id'] ?? '',
      status: status,
      userId: map['userId'] ?? map['user_id'] ?? '',
      userName: map['userName'] ?? map['user_name'] ?? '',
    );
  }
}
