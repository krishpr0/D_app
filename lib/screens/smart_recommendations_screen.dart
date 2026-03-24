import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schoolapp/models/recommendation_model.dart';
import '../models/assignment_model.dart';
import '../services/recommendation_service.dart';
import '../services/study_timer_service.dart';


class SmartRecommendationsScreen extends StatefulWidget {
  final List<Assignment> assignments;

  const SmartRecommendationsScreen({
    super.key,
    required this.assignments,
  });

  @override 
  State<SmartRecommendationsScreen> createState() => _SmartRecommendationsScreenState();
}

class _SmartRecommendationsScreenState extends State<SmartRecommendationsScreen> {
  late RecommendationService _recommendationService;
 String _prediction = '';
 int _selectedIndex = 0;


 @override
 void initState() {
  super.initState();
  final timerService = Provider.of<StudyTimerService>(context, listen: false);
  _recommendationService = RecommendationService(timerService);
 } 


 @override
 Widget build(BuildContext context) {
  final recommendations = _recommendationService.getRecommendations(widget.assignments);

  return DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Smart Assistant'),
        bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.recommend), text: 'Recommendation'),
            Tab(icon: Icon(Icons.schedule), text: 'Schedule'),
            Tab(icon: Icon(Icons.analytics), text: 'Predictions'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          _buildRecommendationsTab(recommendations),
          _buildScheduleTab(),
          _buildPredictionsTab(),
       ],
      ),
    ),
  );
 }

    Widget _buildRecommendationsTab(List<AssignmentRecommendation> recs) {
      if (recs.isEmpty) {
        return const Center(
          child: Text('YAYAYAYA no more pending assignments!, Great',
          textAlign: TextAlign.center,
        ),
      );
    }


    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recs.length,
      itemBuilder: (context, index) {
        final rec = recs[index];
        final assignment = rec.assignment;


        return Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getPriorityColor(rec.priorityScore),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12),),
                ),

                child: Row(
                  children: [
                    Icon(index == 0 ? Icons.emoji_events : Icons.lightbulb, 
                    color: Colors.white,
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        index == 0 ? 'Top Recommendation' : 'recommendation ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Text('${rec.priorityScore.toInt()}% match',
                    style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text('Subject: ${assignment.subject}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.timer,
                          '${rec.estimatedHours}h estimated',
                          Colors.orange,
                        ),

                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.priority_high,
                          assignment.priority.toString().split('.').last,
                          _getPriorityColorFromEnum(assignment.priority),
                        ),

                        const SizedBox(width: 8),
                        _buildInfoChip(
                          Icons.calendar_today,
                          _formatDate(assignment.deadline),
                          rec.isOverdue ? Colors.red : Colors.green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),

                      child: Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              rec.reason,
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _startStudySession(assignment);
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start studying'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            _showAssignmentDetails(assignment);
                          },

                          icon: const Icon(Icons.info_outline),
                          tooltip: 'Details',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
 }



    Widget _buildScheduleTab() {
      final availableHours = 4;
      final schedule = _recommendationService.createOptimalSchedule(
        widget.assignments,
        availableHours,
      );

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Todays Recommeded Schedule',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),
                    Text('Based on ur work, we suggest stuyding for ${schedule.totalHoursPlanned} hours today',
                    textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          ...schedule.schedule.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: Icon(Icons.book, color: Colors.blue),
                title: Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Text('${entry.value.length} study sessions'),
                children: entry.value.map((slot) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${slot.startTime.hour}:00'),
                    ),

                    title: Text(slot.task),
                    subtitle: Text('${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)} (${slot.duration}h)',),
                    trailing: Checkbox(
                      value: slot.isCompleted,
                      onChanged: (value) {
                        setState(() {
                            //MARKS AS COMPELTED hmm
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      );
    }

    Widget _buildPredictionsTab() {
      final pendingAssignments = widget.assignments.where((a) =>
      a.status != AssignmentStatus.Completed).toList();

      return FutureBuilder(
        future: _loadPredictions(pendingAssignments),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.psychology, size: 48, color: Colors.purple),
                      SizedBox(height: 12),
                      Text('AI Study Predictor',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text('Based on your study patteners',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              ...pendingAssignments.map((assignment) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getPriorityColorFromEnum(
                          assignment.priority),
                      child: Text(assignment.priority
                          .toString()
                          .split('.')
                          .last[0]),
                    ),
                    title: Text(assignment.title),
                    subtitle: Text(_prediction),
                    onTap: () => _showAssignmentDetails(assignment),
                  ),
                );
              }),
            ],
          );
        },
      );
    }

    Future<void> _loadPredictions(List<Assignment> assignments) async {
   if (assignments.isNotEmpty) {
     _prediction = await _recommendationService.predictCompletionTime(assignments[0]);
     setState(() {});
   }
 }


 void _startStudySession(Assignment assignment) {
   Navigator.pushNamed(
     context,
     '/study',
     arguments: assignment.subject,
   );
 }


 void _showAssignmentsDetails(Assignment assignment) {
   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       title: Text(assignment.title),
       content: Column(
         mainAxisSize: MainAxisSize.min,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text('Subject: ${assignment.subject}'),
           const SizedBox(height: 8),
           Text('Description: ${assignment.description}'),
           const SizedBox(height: 8),
           Text('Due: ${_formatDate(assignment.deadline)}'),
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


 Widget _buildInfoChip(IconData icon, String label, Color color) {
   return Chip(
     avatar: Icon(icon, size: 16, color: color),
     label: Text(
       label,
       style: TextStyle(fontSize: 12, color: color),
     ),

     backgroundColor: color.withOpacity(0.1),
     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
   );
 }


 Color _getPriorityColor(double score) {
   if (score >= 80) return Colors.red;
   if (score >= 60) return Colors.orange;
   if (score >= 40) return Colors.yellow.shade700;
   return Colors.green;
 }



Color _getPriorityColorFromEnum(Priority p) {
  switch (p) {
    case Priority.Low: return Colors.green;
    case Priority.Medium: return Colors.orange;
    case Priority.High: return Colors.red;
    case Priority.Urgent: return Colors.purple;
  }
}

String _formatDate(DateTime date) {
    final diff = date.difference(DateTime.now()).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tommorow';
    if (diff < 0) return 'Overdue';
    return 'In $diff days';
}
String _formatTime(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
 
}