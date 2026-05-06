import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dashboard_service.dart';
import '../models/assignment_model.dart';



class DashboardScreen extends StatelessWidget {
  final List<Assignment> assignments;
  final Function(Assignment, int) onAssignmentTap;

  const DashboardScreen({
    super.key,
    required this.assignments,
    required this.onAssignmentTap,
  });



  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Dashboard'),
        backgroundColor: Colors.teal,
      ),

      body: RefreshIndicator(
        onRefresh: () async => Future.delayed(const Duration(seconds: 1)),
        child: Consumer<DashboardService>(
          builder: (context, service, child) {
            final upcoming = service.getUpcomingAssignments(assignments);
            final overdue = service.getOverdueAssignments(assignments);
            final completionRate = service.getCompletionRate(assignments);
            final totalPending = service.getTotalPending(assignments);
            final priorityBreakdown = service.getPriorityBreakdown(assignments);



            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Streak card
                  _buildStreakCard(service.studyStreak),
                  const SizedBox(height: 16),

                  //Stats Grid
                  _buildStatsGrid(completionRate, totalPending, assignments.length),
                  const SizedBox(height: 16),

                  //Priority breakdown
                  _buildPrioritySection(priorityBreakdown),
                  const SizedBox(height: 16),
                  
                  //overdue
                  if (overdue.isNotEmpty) ...[
                    _buildSectionHeader('Overdue', Colors.red),
                    ...overdue.map((a) => _buildAssignmentTile(a, context, true)),
                  ],

                  //Upcoming section
                  _buildSectionHeader('Upcoming', Colors.blue),
                  if (upcoming.isEmpty) 
                  const Padding (
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No Upcoming assignments~')),
                  )
                  else ...upcoming.map((a) => _buildAssignmentTile(a, context, false)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }



  Widget _buildStreakCard(int streak) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                '$streak Day${streak != 1? 's' : ''}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text('Study Streak!', style: TextStyle(color: Colors.white70),),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildStatsGrid(double completionRate, int pending, int total) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Completion', 
            '${completionRate.toStringAsFixed(0)}%',
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Pending',
            '$pending',
            Colors.orange,
            Icons.pending_actions,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total',
            '$total',
            Colors.blue,
            Icons.assignment,
          ),
        ),
      ],
    );
  }




  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }



  Widget _buildPrioritySection(Map<String, int> breakdown) {
   if (breakdown.isEmpty) return const SizedBox.shrink();

   return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Priority Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...breakdown.entries.map((entry) {
              Color color;
              switch (entry.key) {
                case 'Urgent' : color = Colors.deepPurple; break;
                case 'High' : color = Colors.red; break;
                case 'Medium' : color = Colors.orange; break;
                default: color = Colors.green;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Text('${entry.value} pending', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              );
          }),
        ],
      ),
    ),
   );
  }



  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title, 
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }



  
  Widget _buildAssignmentTile(Assignment a, BuildContext context, bool isOverdue) {
    final index = assignments.indexOf(a);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(a.priority),
          child: Text(
            a.priority.toString().split('.').last[0],
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        title: Text(a.title, style: TextStyle(fontWeight: FontWeight.bold, color: isOverdue ? Colors.red : null,),),
        subtitle: Text('${a.subject} - Due ${_formatDate(a.deadline)}'),
        trailing: isOverdue ? const Icon(Icons.warning, color: Colors.red) : Text(_daysLeft(a.deadline), style: const TextStyle(color: Colors.grey)),
        onTap: () => onAssignmentTap(a, index),
      ),
    );
  }



  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'Today';
    } 
    if (date.difference(now).inDays == 1) {
      return 'Tomorrow';
    }
    return '${date.day}/${date.month}';
  }

  String _daysLeft(DateTime deadline) {
    final days = deadline.difference(DateTime.now()).inDays;
    if (days <= 0) return 'Overdue';
    if (days == 1) return 'Tomorrow';
    return '$days days left';
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.Low: return Colors.green;
      case Priority.Medium: return Colors.orange;
      case Priority.High: return Colors.red;
      case Priority.Urgent: return Colors.deepPurple;
    }
  }
}