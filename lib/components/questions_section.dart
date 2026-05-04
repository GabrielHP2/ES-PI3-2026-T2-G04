import 'package:flutter/material.dart';
import 'package:frontend/models/question.dart';

class QuestionsSection extends StatefulWidget {
  final String title;

  const QuestionsSection({super.key, required this.title});

  @override
  State<QuestionsSection> createState() => _QuestionsSectionState();
}

class _QuestionsSectionState extends State<QuestionsSection> {
  final List<Question?> _questions = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _questions.isEmpty
          ? ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final Question question = _questions[index]!;
              },
            )
          : const Center(child: Text('Nenhuma pergunta registrada')),
    );
  }
}

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(child: Column());
  }
}
