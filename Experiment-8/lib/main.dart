import 'package:flutter/material.dart';

void main() => runApp(const QuizApp());

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Quiz App',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const QuizPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Question {
  final String text;
  final List<String> answers;
  final String correctAnswer;

  const Question({
    required this.text,
    required this.answers,
    required this.correctAnswer,
  });
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final List<Question> _questions = const [
    Question(
      text: 'What is the capital of India?',
      answers: ['Mumbai', 'Delhi', 'Goa', 'Pune'],
      correctAnswer: 'Delhi',
    ),
    Question(
      text: 'Which planet is known as the Red Planet?',
      answers: ['Earth', 'Mars', 'Venus', 'Jupiter'],
      correctAnswer: 'Mars',
    ),
    Question(
      text: 'Who developed Flutter?',
      answers: ['Apple', 'Google', 'Microsoft', 'Amazon'],
      correctAnswer: 'Google',
    ),
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizFinished = false;

  void _answerQuestion(String selectedAnswer) {
    final current = _questions[_currentQuestionIndex];

    setState(() {
      if (selectedAnswer == current.correctAnswer) {
        _score++;
      }

      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _quizFinished = true;
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _quizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _questions.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz App')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _quizFinished
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Quiz Completed!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold) ??
                            const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your Score: $_score / $total',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _restartQuiz,
                        child: const Text('Restart Quiz'),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} / $total',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _questions[_currentQuestionIndex].text,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    ..._questions[_currentQuestionIndex].answers.map(
                      (answer) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () => _answerQuestion(answer),
                          child: Text(answer),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Score: $_score',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
