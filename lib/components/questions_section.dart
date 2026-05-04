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
    questionText: 'Qual o market share da startup? ',
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

  // Integrar com o service das questions, que chama a function.
  @override
  void initState() {
    super.initState();
    questions.add(questionExemple1);
    questions.add(questionExemple2);
    questions.add(questionExemple1);
    questions.add(questionExemple2);
    questions.add(questionExemple1);
    questions.add(questionExemple2);
    questions.add(questionExemple1);
    questions.add(questionExemple2);
    questions.add(questionExemple2);
  }

  Future<void> _submitQuestion() async {
    //Submit logic, call new question function
    print('submit');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: questions.isNotEmpty
              ? ListView.separated(
                  itemBuilder: (context, index) {
                    final Question question = questions[index];
                    return QuestionCard(question: question);
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemCount: questions.length,
                )
              : const Center(child: Text('Nenhuma pergunta registrada')),
        ),
        TextField(
          maxLength: 180,
          decoration: InputDecoration(
            labelText: 'Faça sua pergunta',

            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                _submitQuestion();
              },
              icon: const Icon(Icons.send),
            ),
          ),
        ),
      ],
    );
  }
}

class QuestionCard extends StatelessWidget {
  final Question question;

  const QuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          text: 'Pergunta de: ',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontWeight: .bold,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: question.userName,
                              style: TextStyle(
                                fontWeight: .bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(question.questionText),
              ],
            ),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 1,
              ),
            ],
          ),
          child: question.isAnswered
              ? Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text.rich(
                              TextSpan(
                                text: 'Resposta de: ',
                                style: TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: .bold,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: question.answeredByName,
                                    style: TextStyle(
                                      fontWeight: .bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text('  ${question.answerText}'),
                    ],
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Center(
                    child: Text(
                      textAlign: .center,
                      'Sem respostas para esta pergunta',
                      style: TextStyle(color: Colors.red, fontWeight: .bold),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
