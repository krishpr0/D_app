import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/question_service.dart';
import '../models/question_model.dart';



class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});


  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}


class _QuestionBankScreenState extends State<QuestionBankScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSubject = 'All';
  QuestionDifficulty? _selectedDifficulty;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Bank'),
        backgroundColor: Colors.indigo,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.quiz), text: 'Practice'),
            Tab(icon: Icon(Icons.assignment), text: 'Tests'),
            Tab(icon: Icon(Icons.analytics), text: 'Results'),
          ],
        ),
      ),

      body: Consumer<QuestionService>(
        builder: (context, service, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildPracticeTab(service),
              _buildTestsTab(service),
              _buildResultsTab(service),
           ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateQuestionDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Create Question (Teacher)',
      ),
    );
  }



  Widget _buildPractiveTab(QuestionService service) {
        final filteredQuestions = service.question.where((q) {
          if (_selectedSubject != 'All' && q.subject != _selectedSubject) return false;
          if (_selectedDifficulty != null && q.difficulty != _selectedDifficulty) return false;
          return true;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),

                      items: [
                        const DropdownMenuItem(value: 'All', child: Text('All Subjects')),
                        ...getAllSubjects().map((s) => DropdownMenuItem(value: s, child: Text(s))),
                      ],
                      onChanged: (value) => setState(() => _selectedSubject = value ?? 'All'),
                    ),
                  ),

                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<QuestionDifficulty>(
                      value: _selectedDifficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),

                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All lvls')),
                        ...QuestionDifficulty.values.map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d.toString().split('.').last.toUpperCase()),
                        )),
                      ],
                      onChanged: (value) => setState(() => _selectedDifficulty = value),
                    ),
                  ),
                ],
              ),
            ),

            //Question list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.al[16],
                itemCount: filteredQuestions.length,
                itemBuilder: (context, index) {
                  final q = filteredQuestions[index];
                  return _buildQuestionCard(q);
                },
              ),
            ),
          ],
        );
      }



      Widget _buildQuestionCard(Duration  question) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(question.difficulty),
                    shape: BoxShape.circle,
                  ),

                  child: Center(
                    child: Text(
                      question.points.toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                title: Text(
                  question.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Text(
                  '${question.subject} ${question.type.toString().split('.').last}',
                  style: const TextStyle(fontSize: 12),
                ),

                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(question.questionText, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        _buildAnswerInput(question),
                        const SizedBox(height: 16),
                        if (question.explanation.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                          ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Explanation', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(question.explanation),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
        }



        Widget _buildAnswerInput(Question question) {
          switch (question.type) {
            case QuestionType.multipleChoice;
            return Column(
              children: List.generate(question.options.length, (index) {
                return RadioListTile<int>(
                  title: Text(question.options[index]),
                  value: index,
                  groupValue: null,
                  onChanged: (value) {
                    final isCorrect = value == question.correctOptionIndex;
                    _showAnswerFeedback(isCorrect);
                  },
                );
              }),
            );

            case QuestionType.trueFalse:
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _checkTextAnswer(question, 'true'),
                      child: const Text('True'),
                    ),
                  ),

                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _checkTextAnswer(question, 'false'),
                      child: const Text('False'),
                    ),
                  ),
                ],
              );

            default: return TextField(
              decoration: const InputDecoration(
                hintText: 'Type your answer here...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _checkTextAnswer(question, value),
            );
          }
        }


        void _checkTextAnswer(Question question, String answer) {
          final isCorrect = answer.toLowerCase().trim() == question.correctAnswer?.toLowerCase().trim();
          _showAnswerFeedback(isCorrect);
        }


        void _showAnswerFeedback(bool isCorrect) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'NoICE' : 'innocrrect T-T'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }



  Widget _buildTestsTab(QuestionService service) {
    final questionSets = service.getQuestionSetsForSubject(_selectedSubject == 'All' ? '' : _selectedSubject);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questionSets.length,
      itemBuilder: (context, index) {
        final set = questionSets[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.assignment, size: 40, color: Colors.indigo),
            title: Text(set.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${set.questionIds.length} question - ${set.timeLimitMinutes} min - ${set.totalPoints} pts',
            ),
            trailing: const Icon(Icons.play_arrow),
            onTap: () => _startTest(set),
          ) ,
        );
      },
    );
  }



  Widget _buildResultsTab(QuestionService service) {
    final results = service.getTestResultsForUser();
    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No Tests yet'),
            Text('Pratice to see ur reuslts'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getGradeColor(result.grade),
              child: Text(result.grade),
            ),

            title: Text('Score: ${result.score}/${result.totalpoints}'),
            subtitle: Text('${result.percentage.toStringAsFixed(1)}% - ${result.timeSpentSeconds ~/ 60} min',
            ),

            trailing: Text(result.completedAt.toLocal().toString().split(' ')[0],
            style: const TextStyle(fontSize: 12),
            ),
            onTap: () => _showResultDetails(result),
          ),
        );
      },
    );
  }


  void _startTest(QuestionSet questionSet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestScreen(questionSet: questionSet),
      ),
    );
  }


  void _showResultDetails(TestResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Test Results - ${result.grade}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: ${result.score}/${result.totalPoints}'),
            Text('Percentage: ${result.percentage.toStringAsFixed(1)}%'),
            Text('Time: ${result.timeSpentSeconds ~/ 60} min ${result.timeSpentSeconds  % 60} sec'),
            const SizedBox(height: 16),
            Text(result.feedback, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }


  void _showCreateQuestionDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateQuestionDialog(),
    );
  }

  Color _getDifficultyColor(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy return Colors.green;
      case QuestionDifficulty.medium return Colors.orange;
      case QuestionDifficulty.hard return Colors.red;
      case QuestionDifficulty.expert return Colors.purple;
    }
  }


  Color _getGradeColor(String grade) {
    if (grade.contains('A')) return Colors.green;
    if (grade.contains('B')) return Colors.blue;
    if (grade.contains('C')) return Colors.orange;
    return Colors.red;
  }
}



class TestScreen extends StatefulWidget {
  final QuestionSet questionSet;
  const TestScreen({super.key, required this.questionSet});

  @override
  State<TestScreen> createState() => _TestScreenState();
}



class _TestScreenState extends State<TestScreen> {
  int _currentIndex = 0;
  final Map<String, dynamic> _answers = {};
  int _timeRemaining = 0;


  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.questionSet.timeLimitMinutes * 60;
    _startTimer();
  }


  void _startTimer() {
    Future.doWhile(() async{
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          if (_timeRemaining > 0) {
            _timeRemaining--;
          }
        });
      }
      return _timeRemaining > 0 && mounted;
    }).then((_) {
      if (_timeRemaining == 0 && mounted) {
      _submitTest();
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.questionSet.title),
        backgroundColor: Colors.indigo,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('${_timeRemaining ~/ 60}:${(_timeRemaining % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),

      body: Consumer<QuestionService>(
          builder: (context, service, child) {
            final questions = service.question.where((q) => widget.questionSet.questionIds.contains(q.id)).toList();
            if (questions.isEmpty) {
              return const Center(child: Text('No qns Found'));
            }

            final currentQuestion = questions[_currentIndex];

            return Column(
              children: [
                //Profgres bar
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / questions.length,
                  backgroundColor: Colors.grey[300],
                  color: Colors.indigo,
                  minHeight: 4,
                ),

                //Qns Counter
                Padding (
                  padding: const EdgeInsets.all(16),
                  child: Text('Question ${_currentIndex + 1} of ${questions.length}',
                  style: const TextStyle(fontSize: 16),
                  ),
                ),

                //Qns card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            //poimrs
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Text('${currentQuestion.points} pointr',
                              style: const TextStyle(color: Colors.indigo),
                              ),
                            ),
                            const SizedBox(height: 16),

                            //qns Text
                            Text(
                              currentQuestion.questionText,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),

                            //Ans intput
                            _buildAnswerInput(currentQuestion, service),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),


                //Navigation Buttons
                Padding(
                  padding: const EdgeInsets.alL(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentIndex > 0)
                        ElevatedButton(
                          onPressed: () => setState(() => _currentIndex--),
                          child: const Text('Previous'),
                        ),

                      if (_currentIndex < questions.length - 1)
                        ElevatedButton(
                          onPressed: () => setState(() => _currentIndex++),
                          child: const Text('next'),
                        ),

                      if (_currentIndex == questions.length - 1)
                        ElevatedButton(
                          onPressed: _submitTest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Submit Test'),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
      ),
    );
  }


  Widget _buildAnswerInput(Question question, QuestionService service) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return Column(
          children: List.generate(question.options.length, (index) {
            return RadioListTile<int>(
              title: Text(question.options[index]),
              value: index,
              groupValue: _answers[question.id],
              onChanged: (value) {
                setState(() {
                  _answers[question.id] = value;
                });
              },
            );
          }),
        );

      default:
        return TextField(
          decoration: const InputDecoration(
            hintText: 'Type ur ans here',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _answers[question.id] = value;
          },
        );
    }
  }


  void _submitTest() async {
    final service = Provider.of<QuestionService>(context, listen: false);
    final result = await service.submitTest(
      widget.questionSet.id,
      _answers,
        (widget.questionSet.timeLimitMinutes * 60) - _timeRemaining,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test cOmpleted! Score: ${result.score}/${result.totalPoints}'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}




class CreateQuestionDialog extends StatefulWidget {
  const CreateQuestionDialog({super.key});


  @override
  State<CreateQuestionDialog> createState() => _CreateQuestionDialogState();
}



class _CreateQuestionDialogState extends State<CreateQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _questionController = TextEditingController();
  final _explanationController = TextEditingController();
  String _selectedSubject = '';
  QuestionType _selectedType = QuestionType.multipleChoice;
  QuestionDifficulty _selectedDifficulty = QuestionDifficulty.medium;
  List<String> _options = ['','','',''];
  int _correctOption = 0;
  int _points = 10;


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create new qns'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Qns title'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 8),
                TextFormField(
                  controller: _questionController,
                  decoration: const InputDecoration(labelText: 'Qns text'),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSubject.isEmpty ? null : _selectedSubject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: getAllSubjects().map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedSubject = value ?? ''),
                ),

                const SizedBox(height: 8),
                DropdownButtonFormField<QuestionType>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: 'Qns Type'),
                  items: QuestionType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),

                const SizedBox(height: 8),
                DropdownButtonFormField<QuestionDifficulty>(
                  value: _selectedDifficulty,
                  decoration: const InputDecoration(labelText: 'Difficulty'),
                  items: QuestionDifficulty.values.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(d.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedDifficulty = value!),
                ),

                const SizedBox(height: 8),
                TextFormField(
                  controller: _explanationController,
                  decoration: const InputDecoration(labelText: 'Explanation'),
                  maxLines: 2,
                ),

                const SizedBox(height: 8),
                TextFormField(
                  initialValue: '10',
                  decoration: const InputDecoration(labelText: 'Points'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _points = int.tryParse(v) ?? 10,
                ),

                if (_selectedType == QuestionType.multipleChoice) ...[
                  const SizedBox(height: 16),
                  const Text('Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...List.generate(4, (index) {
                    return TextFormField(
                      initialValue: _options[index],
                      decoration: InputDecoration(labelText: 'Options ${index + 1}'),
                      onChanged: (v) => _options[index] = v,
                    );
                  }),

                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _correctOption,
                    decoration: const InputDecoration(labelText: 'Correct Option'),
                    items: List.generate(4, (i) {
                      return DropdownMenuItem(
                          value: i,
                        child: Text('Options ${i + 1}')
                      );
                    }),
                    onChanged: (value) => setState(() => _correctOption = value!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: _saveQuestion,
          child: const Text('Create'),
        ),
      ],
    );
  }


  void _saveQuestion() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }

    final  question = Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      questionText: _questionController.text,
      type: _selectedType,
      difficulty: _selectedDifficulty,
      options: _selectedType == QuestionType.multipleChoice ? _options: [],
      correctOptionIndex: _correctOption,
      explanation: _explanationController.text,
      subject: _selectedSubject,
      points: _points,
      createdBy: 'Teacher_001',
      createdAt: DateTime.now(),
    );

    final service = Provider.of<QuestionService>(context, listen: false);
    service.createQuestion(question);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Question create successfully')),
    );
  }
}