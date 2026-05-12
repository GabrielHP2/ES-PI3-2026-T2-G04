import 'package:flutter/material.dart';
import 'package:frontend/models/question.dart';
import 'package:frontend/services/question_service.dart';

class QuestionsSection extends StatefulWidget {
  final String startupId;
  final bool isPublic;

  const QuestionsSection({
    super.key,
    required this.startupId,
    required this.isPublic,
  });

  @override
  State<QuestionsSection> createState() => _QuestionsSectionState();
}

class _QuestionsSectionState extends State<QuestionsSection> {
  List<Question?> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _controller = TextEditingController();

  Future<void> _fetchQuestions(String startupId, bool visibility) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await callGetQuestions(startupId, visibility);

    if (!mounted) return;

    setState(() {
      _questions = result;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchQuestions(widget.startupId, widget.isPublic);
  }

  Future<void> _submitQuestion() async {
    setState(() {
      _isLoading = true;
    });
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Campo de pergunta vazio')));
      setState(() {
        _isLoading = false;
      });
      return;
    }
    await callSendQuestion(widget.startupId, widget.isPublic, _controller.text);
    await _fetchQuestions(widget.startupId, widget.isPublic);
    if (!mounted) return;
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(height: 8),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            _fetchQuestions(widget.startupId, widget.isPublic),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _questions.isEmpty
              ? const Center(child: Text('Nenhuma pergunta registrada'))
              : RefreshIndicator(
                  onRefresh: () =>
                      _fetchQuestions(widget.startupId, widget.isPublic),
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      final Question question = _questions[index]!;
                      return QuestionCard(question: question);
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemCount: _questions.length,
                  ),
                ),
        ),
        SizedBox(height: 16),
        TextField(
          maxLength: 180,
          controller: _controller,
          onSubmitted: (value) => _isLoading ? null : _submitQuestion(),
          decoration: InputDecoration(
            labelText: 'Faça sua pergunta',
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            suffixIcon: IconButton(
              onPressed: () => _isLoading ? null : _submitQuestion(),
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
