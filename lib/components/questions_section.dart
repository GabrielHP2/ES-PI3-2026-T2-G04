import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/question.dart';

enum QuestionSectionType { public, private }

class QuestionsSection extends StatefulWidget {
  const QuestionsSection({super.key});

  @override
  State<QuestionsSection> createState() => _QuestionsSectionState();
}

class _QuestionsSectionState extends State<QuestionsSection> {
  final Question questionExemple1 = Question(
    createdAt: Timestamp.now(),
    isAnswered: true,
    isPublic: true,
    questionText: 'Qual o market share da startup?',
    startupId: 'agor-sense',
    status: QuestionStatus.active,
    userId: '0',
    userName: 'João Pedro Panza Mainieri',
    answeredAt: Timestamp.now(),
    answeredById: '1',
    answeredByName: 'Gabriel Giga',
    answerText: '2%',
  );
  final Question questionExemple2 = Question(
    createdAt: Timestamp.now(),
    isAnswered: false,
    isPublic: true,
    questionText: 'Qual o market share da startup?',
    startupId: 'agor-sense',
    status: QuestionStatus.active,
    userId: '0',
    userName: 'João Pedro Panza Mainieri',
    answeredAt: Timestamp.now(),
    answeredById: '1',
    answeredByName: 'Gabriel Giga',
    answerText: '2%',
  );

  final List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    questions.add(questionExemple1);
    questions.add(questionExemple2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: questions.isNotEmpty
          ? Column(
              children: questions
                  .map((question) => QuestionCard(question: question))
                  .toList(),
            )
          : const Center(child: Text('Nenhuma pergunta registrada')),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final Question question;

  const QuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Pergunta de: ',
                      style: TextStyle(color: Colors.indigo),
                    ),
                    SizedBox(width: 10),
                    Text(question.userName),
                  ],
                ),
                Text(question.questionText),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: question.isAnswered
                ? Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Resposta de: ',
                            style: TextStyle(color: Colors.indigo),
                          ),
                          SizedBox(width: 10),
                          Text(question.answeredByName!),
                        ],
                      ),
                      Text(question.answerText!),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Sem respostas para esta pergunta',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
