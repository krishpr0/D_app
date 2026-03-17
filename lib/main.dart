import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(const MyApp());
}

enum AssignmentStatus { Todo, InProgress, Completed }

class Assignment {
  String subject;
  String title;
  String description;
  DateTime deadline;
  String submitTo;
  AssignmentStatus status;


  Assignment({
    required this.subject,
    required this.title,
    required this.description,
    required this.deadline,
    required this.submitTo,
    this.status = AssignmentStatus.Todo,
  });

      factory Assignment.fromJson(Map<String, dynamic> json) {
        return Assignment(
          subject: json['subject'],
          title: json['title'],
          description: json['description'],
          deadline: DateTime.parse(json['deadline']),
          submitTo: json['SubmitTo'],
          status: AssignmentStatus.values[json['status'] ?? 0],
        );
  }

          Map<String, dynamic> toJson() => {
                'subject': subject, 
                'title': title,
                'description': description,
                'deadline': deadline.toIso8601String(),
                'SubmitTo': submitTo,
                'status': status.index,
            };
          }

          
          class MyApp extends StatelessWidget {}
              const MyApp({super.key});


              @override
              Widget build(BuildContext context) {
                return MaterialApp(
                  title: 'Assignment Manager',
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  ),
                  home: const AssignmentManager(),
                  debugShowCheckedModeBanner: false,
                );
              }
            }


                class AssignmentManager extends StatefulWidget {
                  const AssignmentManager({super.key});

                  @override
                  State<AssignmentManager> createState() => _AssignmentManagerState();
                }


                class _AssignmentManagerState extends State<AssignmentManager> {
                  final List<Assignments> _assignments = [];

                  

                  @override 
                  void initState() {
                    super.initState();
                    _loadAssignments();
                  }

                  
                  Future<void> _loadAssignments() async {
                    final prefs = await SharedPreferences.getInstance();
                    final data  = prefs.getStringList('assignments') ?? [];
                    setState(() {
                      _assignments.clear();
                      _assignments.addAll(data.map((e) => Assignment.fromJson(jsonDecode(e))));
                  });
                  }


                  
                }


