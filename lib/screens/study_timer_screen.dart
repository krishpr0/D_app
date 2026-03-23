import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/study_timer_service.dart';
import '../main.dart';


class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen> {
  final TextEditingController _noteController = TextEditingController();
  int _selectedRating = 0;
  String _selectedSubject = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudyStatisticsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Consumer<StudyTimerScreen>(
        builder: (context, timer, child) {
          if (timer.isRunning) {
            return _buildActiveTimer(timer);
          }
          return _buildStartTimer(timer);
        },
      ),
    );
  }


  Widget _buildStartTimer(StudyTimerService timer) {
    final subjects = getAllSubjects();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            const Text('Ready to Focuz', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}