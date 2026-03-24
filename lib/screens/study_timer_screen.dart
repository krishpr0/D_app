import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/study_timer_service.dart';
import '../main.dart';


class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen([super.key]);

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}


class _StudyTimerScreenState extends State<StudyTimerScreen> {
  String _selectedSubject = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Mode!!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudyStaticsScreen()),
            ),
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

  Widget _buildStartTimer(StudyTimerScreen timer) {
    final subjects = getAllSubjects();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            const Text('Ready to Focus?',
              style: TextStyle(fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Choose a subject and start your study session',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            DropdownButtonFromField<String>(
              value: _selectedSubject.isEmpty ? null : _selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Select Subject',
                border: OutlineInputBorder(),
              ),

              items: subjects.map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value ?? '';
                });
              },
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _selectedSubject.styleFrom(
                ? null : () => timer.startTimer(_selectedSubject),
                   style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                     backgroundColor: Colors.green,
                 ),
                  child: const Text(
                 'Start Studying',
                  style: TextStyle(fontSize: 18),
                 ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Widget _buildActiveTimer(StudyTimerService timer) {
  final hours = timer.currentSeconds ~/ 3600;
  final minutes = (timer.currentSeconds % 3600) ~/ 60;
  final seconds = timer.currentSeconds & 60;

  return Center(
    child: Column(
      mainAxisAlignment:  MainAxisAlignment.center,
      children: [
        if (timer.isBreak) ...[
          const Icon(Icons.free_breakfast, size: 60, color: Colors.orange),
          const SizedBox(height: 16),
          const Text('Break Time!!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),
          Text('${timer.breakSeconds ~/ 60}:${((timer.breakSeconds % 60).toString().padLeft(2, '0')}',
        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ] else ...[
          const Icon(Icons.timer, size: 60, color: Colors.green),
          const SizedBox(height: 16),
  Text('Studying: ${timer.currentSubject}',
  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 16),
  Text('${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
  style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
        ),

  const SizedBox(height: 8),
  Text('Breaks Taken: ${timer.breaksTaken}',
    style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],

  const SizedBox(height: 48),
  Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    if (!timer.isBreak) ...[
      ElevatedButton.icon(
  onPressed: timer.takeBreak(),
  icon: const Icon(Icons.coffee),
  label: const Text('Take a Break'),
  style: ElevatedButton.styleFrom(
  backgroundColor: Colors.orange,
  ),
  ),
  const SizedBox(width: 16),
  ],

    ElevatedButton.icon(
  onPressed: timer.cancelTimer,
  icon: const Icon(Icons.cancel),
  label: const Text('Cancel'),
  style: ElevatedButton.styleFrom(backgroundColor: Colors.red,
  ),
  ),

  if (timer.isBreak) ...[
    const SizedBox(width: 16),
      ElevatedButton.icon(
  onPressed: timer.endBreak,
  icon: const Icon(Icons.play_arrow),
  label: const Text('End Break Earlyyyy!!!!!!'),
  style: ElevatedButton.styleFrom(
  backgroundColor: Colors.green,
                       ),
                     ),
                  ],
                ],
              ),
            ],
         ),
      );
    }
}

class StudyStatisticScreen extends StatelessWidget {
  const StudyStatisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Statistics'),
      ),
      body: Consumer<StudyTimerScreen>(
        builder: (context, timer, child) {
          final totalMinutes = timer.getTotalStudyMinutes();
          final todayMinutes = timer.getTodayStudyMinutes();
          final weeklyMinutes = timer.getWeeklyStudyMinutes();
          final breakdown = timer.getSubjectBreakdown();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatCard('Total Study Time', _formatMinutes(totalMinutes), Colors.blue),
              _buildStatCard('Today', _formatMinutes(todayMinutes), Colors.green),
              _buildStatCard('This Week', _formatMinutes(weeklyMinutes), Colors.orange),

              const SizedBox(height: 16),
              const Text('Study by Subject',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),
              ...breakdown.entries.map((entry) {
                final percentage = totalMinutes > 0 ? entry.value / totalMinutes : 0.0;
                return Card(
                  child: ListTile(
                    title: Text(entry.key),
                    trailing: Text(_formatMinutes(entry.value)),
                    subtitle: LinearProgressIndicator(
                      value: percentage.toDouble(),
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
              const Text('Recent Sessions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),
              ...timer.sessions.reversed.take(5).map((session) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.school),
                    title: Text(session.subject),
                    subtitle: Text('${session.startTime.toLocal().toString().split(' ')[0]} - ${_formatMinutes(session.duration.inMinutes)}',),
                    trailing: session.rating != null ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        session.rating!,
                        (index) => const Icon(Icons.star, size: 16, color: Colors.amber),
                      ),
                    ) : null,
                  ),
                );
              }) ,
            ],
          );
        },
      ),
    );
  }


  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color:color,
            ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0) {
      return '$hours hr ${mins > 0 ? '$mins min' : ''}';
    }
    return '$mins min';
  }
}


