import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

enum AssignmentStatus { Todo, InProgress, Completed}

class Assignment {
  String subject;
  String title;
  String description;
  DateTime deadline;
  String submitTo;
  AssignmentStatus status;
  DateTime? startDate;
  DateTime? completionDate;

  Assignment({
    required this.subject,
    required this.title,
    required this.description,
    required this.deadline,
    required this.submitTo,
    this.status = AssignmentStatus.Todo,
    this.startDate;
    this.completionDate,
  });

  factory Assignment.fromJson(Map<String, dynamic> josn) {
    return Assignment(
      subject: json['subject'],
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      submitTo: json['submitTo'],
      status: AssignmentStatus.values[json['status'] ?? 0],
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startSDate']) : null,
      completionDate: json['completionDate'] != null ? DateTime.tryParse(json['completionDate']) : null,
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'subject': subject,
        'title': title,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'submitTo': submitTo,
        'status': status.index,
        'startDate': startDate?.toIso8601String(),
        'comepletionData': completionDate?.toIso8601String(),
      };
    } 
        class MyApp extends StatelessWidget {
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


                class  _AssignmentManagerState extends State<AssignmentManager> {
                  final List<Assignment> _assignments = [];


                  @override
                    void initState(){
                      super.initState();
                      _loadAssignments();
                    }

                    Future<void> _loadAssignments() async {
                      final prefs = await SharedPreferences.getInstance();
                      final data = prefs.getStringList('assignments') ?? [];
                      setState(() {
                        _assignments.clear();
                        _assignments.addAll(data.map((e) => Assignment.fromJson(jsonDecode(e))));
                      });
                    }


                    Future<void> _saveAssignments() async {
                      final prefs = await SharedPreferences.getInstance();
                      final data = _assignments.map((a) => jsonEncode(a.toJson())).toList();
                      await prefs.setStringList('assignments', data);
                    }

                    void _addOrEditAssignment({Assignment? assignment, int?index}) async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignmentForm(assignment: assignment),
                        ),
                      );
                      if (result != null && result is Assignment) {
                        setState(() {
                          if (index != null) {
                            _assignments[index] = result;
                          } else {
                            _assignments.add(result);
                          }
                        });
                        await _saveAssignments();
                      }
                    }

                    void _removeAssignment(int index) async {
                      setState(() {
                        _assignments.removeAt(index);
                      });
                      await _saveAssignments();
                    }


                    void _showAssignmentDetail(Assignment assignment, int index) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignmentDetail(
                            assignment: assignment,
                            onEdit: () => _addOrEditAssignment(assignment: assignment, index: index),
                            onDelete: (){
                              _removeAssignment(index);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    }


                        Widget buildKanbanBoard() {
                          Map<AssignmentStatus, List<Assignment>> statusMap = {
                            AssignmentStatus.Todo: [],
                            AssignmentStatus.InProgress: [],
                            AssignmentStatus.Completed: [],
                          };

                          for (var a in _assignments) {
                            statusMap[a.status]?.add(a);
                          }

                          final double kanbanHeight = (MediaQuery.of(context).size.height - kToolbarHeight - 100).clamp(200.0, double.infinity);

                      
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          heightL kanbanHeight,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            childern: AssignmentStatus.values.map((status) {
                                return SizedBox(
                                  width : 260,
                                  child: DragTarget<Assignment>(
                                    onWillAccept: (assignment) {
                                      if (assignment == null) return false;
                                      if (status == AssignmentStatus.InProgress && assignment.status == AssignmentStatus.Todo) return true;
                                      if (status == AssignmentStatus.Completed && assignment.status == AssignmentStatus.InProgress) return true;
                                      return false; 
                                    },

                                    onAccept: (assignment) async {
                                      WidgetBinding.instance.addPostFrameCallback((_) async{
                                        setState(() {
                                          final index = _assignments.indexOf(assignment);
                                          if (index != -1) {
                                            if (status == AssignmentStatus.InProgress && assignment.status == AssignmentStatus.Todo) {
                                              assignment.status = AssignmentStatus.InProgress;
                                              assignment.startDate = DateTime.now();
                                            } else if (status == AssignmentStatus.Completed && assignment.status == AssignmentStatus.InProgress) {
                                              assignment.status = AssignmentStatus.Completed;
                                              assignment.completionDate = DateTime.now();
                                            }
                                            _assignments[index] = assignment;
                                          }
                                        });
                                        await _saveAssignments();
                                      });
                                    },
                                    builder: (context, candidateDate, rejectedData) => Card(
                                      margin: const EdgeInsets.all(8),
                                      child: Column(
                                        childern: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              status.toString().split('.').last.replaceAllMapped(
                                                RegExp(r'([A-Z])'),
                                                (m) => '${m[1]}',
                                              ).toUpperCase(),
                                              style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      color: status == AssignmentStatus.Todo ? Colors.orange : status == AssignmentStatus.InProgress ? Colors.blue : Colors.green,
                                              ),
                                            ),
                                          ),

                                          if (candidateDate.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text('Drop here', style: TextStyle(color: Colors.blue)),
                                          ),

                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: statusMap[status!.length,
                                              itemBuilder: (context, index) {
                                                final assignment = statusMap[status]![index];
                                                return Draggable<Assignment>(
                                                  data: assignment,
                                                  feedback: SizedBox(
                                                    width: 240,
                                                    child: Card (
                                                      child: ListTile(
                                                        title: Text(assignment.title),
                                                        subtitle; Text(assignment.subject),
                                                      ),
                                                    ),
                                                  ),

                                                  child: ListTile(
                                                    title: Text(assignment.title),
                                                    subtitle: Text(assignment.subject),
                                                    onTap: () => _showAssignmentDetail(assignment, _assignments.indexOf(assignment)),
                                                  ),
                                                );
                                              },
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                            }).toList(),
                          ),
                        ),
                      );
                    }
                                  
                              @override
                              Widget build(BuildContext context) {
                                return Scaffold(
                                  appBar: AppBar(title: const Text('Assignment Manager')),
                                  body: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      childern: [
                                        ElevatedButton(
                                          onPressed: () => _addOrEditAssignment(),
                                          child: const Text('Add Assignment'),
                                        ),
                                        const SizedBox(height: 20),
                                        Expanded(child: buildKanbanBoard()),
                                      ],
                                    ),
                                  ),
                                );
                              }                    
                                  
                              class AssignmentForm extends StatefulWidget {
                                final Assignment? assignment;
                                const AssignmentForm({super.key, this.assignment});

                                @override
                                State<AssignmentForm> createState() => _AssignmentFormState();
                              }


                              class _AssignmentFormState extends State<AssignmentForm> {
                                final _formkey = GlobalKey<FormState>();
                                late TextEditingController _subjectController;
                                late TextEditingController _titleController;
                                late TextEditingController _descriptionController;
                                late TextEditingController _submitToController;
                                DateTime? _deadline;
                                

                                          @override
                                          void initState() {
                                            super.initState();
                                            _subjectController = TextEditingController(text: widget.assignment?.subject ?? '');
                                            _titleController = TextEditingController(text: widget.assignment?.title ?? '');
                                            _descriptionController = TextEditingController(text: widget.assignment?.description ?? '');
                                            _submitToController = TextEditingController(text: widget.assignment?.submitTo ?? '');
                                            _deadline = widget.assignment?.deadline; 
                                          }

                                          @override
                                          void dispose() {
                                            _subjectController.dispose();
                                            _titleController.dispose();
                                            _descriptionController.dispose();
                                            _submitToController.dispose();
                                            super.dispose();
                                          }

                                          Future<void> _pickDeadline() async {
                                            final now = DateTime.now();
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: _deadline ?? now,
                                              firstDate: now,
                                              lastDate: DateTime(now.year + 5),
                                            );

                                            if (picked != null) {
                                              setState(() {
                                                _deadline = picked;
                                              });
                                            }
                                          }


                                          @override
                                          Widget build(BuildContext context) {
                                            return Scaffold(
                                              appBar: AppBar(
                                                title: Text(widget.assignment == null ? 'Add Assignment' : 'Edit Assignment'),
                                              ),
                                              body: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Form(
                                                  key: _formKey,
                                                  child: ListView(
                                                    children: [
                                                      
                                                      
                                                      TextFormField(
                                                        controller: _subjectController,
                                                        decoration: const InputDecoration(labelText: 'Subject'),
                                                        validator: (value) => value!.isEmpty ? 'Enter subject' : null,
                                                      ),

                                                      TextFormField(
                                                        controller: _titleController,
                                                        decoration: const InputDecoration(labelText: 'Assignment Title'),
                                                        validator: (value) => value!.isEmpty ? 'Enter title' : null,
                                                      ),

                                                      TextFormField(
                                                        controller: _descriptionController
                                                        decoration: const InputDecoration(labelText: 'Description'),
                                                        maxLines: 3,
                                                        validator: (value) => value!.isEmpty ? 'Enter description' : null,
                                                      ),

                                                      TextFormField(
                                                        controller: _subjectToController,
                                                        decoration: const InputDecoration(labelText: 'Submit To'),
                                                        validator: (value) => value!.isEmpty ? 'Enter submit to' : null,
                                                      ),

                                                      const SizedBox(height: 10),
                                                      ListTile(
                                                        title: Text(_deadline == null ? 'Pick Deadline' : 'Deadline ${_deadline!.toLocal().toString().split('')[0]}'),
                                                        trailing: const Icon(Icons.calendar_today),
                                                        onTap: _pickDeadline,
                                                      ),

                                                         if (_deadline == null) 
                                                         const Padding(
                                                          padding: EdgeInsets.only(left: 16.0),
                                                          child: Text('Please select a deadline', style: TextStyle(color: Colors.red)),
                                                         ),

                                                         const SizedBox(height: 20),
                                                         ElevatedButton(
                                                          onPressed: _save,
                                                          child: Text(widget.assignment == null ? 'Add' : 'Update'),
                                                         ),
                                                       ],
                                                     ),
                                                   ),
                                                 ),
                                               );
                                              }

                                              void _save() {
                                                  if (_formKey.currentState!.validate() && _deadline != null) {
                                                    final assignment = Assignment(
                                                      subject: _subjectController.text,
                                                      title: _titleController.text,
                                                      description: _descriptionController.text,
                                                      deadline: _deadline!,
                                                      submitTo: _submitToController.text,
                                                    );
                                                    Navigator.pop(context, assignment);
                                                  }
                                                }
                                              }



                                                class AssignmentDetail extends StatelessWidget {
                                                  final Assignment assignment;
                                                  final VoidCallback onEdit;
                                                  final VoidCallback onDelete;


                                                  const AssignmentDetail({
                                                    super.key,
                                                    required this.assignment,
                                                    required this.onEdit,
                                                    required this.onDelete,
                                                  });


                                                  @override

                                                  Widget build(BuildContext context) {
                                                    return Scaffold(
                                                      appBar: AppBar(
                                                        title: Text(assignment.title),
                                                        actions: [
                                                          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                                                          IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
                                                        ],
                                                      ),

                                                      body: Padding(
                                                        padding: const EdgeInsets.all(16.0),
                                                        child: ListView(
                                                          children: [
                                                            ListTile(title: const Text('Subject'), subtitle: Text(assignment.subject)),
                                                            ListTile(title: const Text('Title'), subtitle: Text(assignment,title)),
                                                            ListTile(title: const Text('Description'), subtitle: Text(assignment.description)),
                                                            ListTile(title: const Text('Deadline'), subtitle: Text(assignment.deadline.toLocal().toString().split('')[0]),
                                                            ),
                                                            ListTile(title: const Text('Submit To'), subtitle: Text(assignment.submitTo)),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }

