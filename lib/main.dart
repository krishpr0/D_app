import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notificiation.dart';
import 'package:table_calendar/table_calendart.dart';

void main() {
  runApp(const MyApp());
}

enum AssignmentStatus { Todo, InProgress, Completed}

enum SubjectName {
  English,
  Mathematics,
  Physics,
  Chemistry,
  Nepali,
  ComputerOrganiztionAndArchitecture,
  OperatingSystem,
  JavaProgramming,
  WebAndMobileApplicationDevelopment,
}

enum TeacherName {
  MrManojSapkota,
  MrSushatAdhikari,
  MrMachaKaji,
  MrSurendraKhadka,
  MrPramondArcharya,
  MsSantoshiThokar,
  MsRejaThapa,
  MsMalikaJoshi,
  MsGeetaKhatri,

}

class Assignment {
  String subject;
  String title;
  String description;
  DateTime deadline;
  String submitTo;
  AssignmentStatus status;
  DateTime? startDate;
  DateTime? completionDate;
  String? imagePath;

  Assignment({
    required this.subject,
    required this.title,
    required this.description,
    required this.deadline,
    required this.submitTo,
    this.status = AssignmentStatus.Todo,
    this.startDate;
    this.completionDate,
    this.imagePath,
  });

class NotificationsService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> scheduleAssignmentReminder(Assignment assignment) async {
    await _notifications.zonedSchedule(
      assignment.hashCode,
      'Assignment Due Soon!',
      '${assignment.title} is due tomorrow',
      _scheduleTime(assignment.deadline),
      const NotificationsDetails(
        android: AndroidNotificationDetails(
          'assignment_channel': Importance.high,
        ),
      ),
      uniLocalNotificationDateInterpretation: uniLocalNotificationDateInterpretation.absoluteTimne,
    );
  }
}


class CalendarPage extends StatefulWidget {
  final List<Assignment> assignments;

    const CalendarPage({super.key, required this.assignments});

    @override
    State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Assignment>> _getAssignmentsByDay() {
    Map<DateTime, List<Assignment>> assignmentsMap = {};

    for (var assignment in widget.assignments) {
      final day = DateTime(assignment.deadline.year, assignment.deadline.month, assignment.deadline.day);
      assignmentsMap[day] = [...assignmentsMap[day] ?? [], assignment];
    }

    return assignmentMap;
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsByDay = _getAssignmentsByDay();


    return Scaffold(
      appBar: AppBar(title: const Text('Calendar View')),
      body: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.now(),
        lastDaty: DateTime.now().add(const Duration(days: 365)),
        eventLoader: (day) => assignmentsByDay{day} ?? [],
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),        
      ),
    );
  }
}

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
      imagePath: json['imagePath'],
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
        'imagePath': imagePath,
      };
    } 

          List<String> dynamicSubjects = [];
          List<String> dynamicTeachers = [];
        
          
          String prettifyEnumName(String name) {
            final withSpaces = name.replaceAllMapped(RegExp(r'([A-z])'), (m) => '${m[1]}');
            return withSpaces[0].toUpperCase() + withSpaces.substring(1);
          }

          List<String> getAllSubjects() {
            return [
              ...Subjective.values.map((e) => prettifyEnumName(e.name)),
              ...dynamicSubjects,
            ];
          }

          List<String> getAllTeachers() {
            return [
              ...TeacherName.values.map((e) => prettifyEnumName(e.name),
              ...dynamicTeachers,)
            ];
          }


          void addsubject(String subject) {
            if (!dynamicSubjects.contains(subject)) {
              dynamicSubjects.add(subject);
            }
          }

          void addTeacher(String teacher) {
            if (!dynamicTeachers.contains(teacher)) {
              dynamicTeachers.add(teacher)''
            }
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

                class DashboardPage extends StatefulWidget {
                  final List<Assignment> assignment;
                  final void Function(Assignment, int) onAssignmentTap;

                  const DashboardPage({
                    super.key,
                    required this.assignments,
                    required this.onAssignmentTap,
                  });

                  @override 
                  State<DashboardPage> createState() => _DashboardPageState();
                }


                class _DashboardPageState extends State<DashboardPage> {
                  AssignmentStatus? _statusFilter;
                  String _search = '';

                  @override
                  Widget build(BuildContext context) {
                    final TodoCount = widget.assignments.where((a) => a.status == AssignmentStatus.Todo).length;
                    final  inProgressCount = widget.assignments.where((a) => a.status == AssignmentStatus.InProgress).length;
                    final completedCount = widget.assignments.where((a) => a.status == AssignmentStatus.Completed).length;
                     

                     final filtered = widget.assignments.where((a) {
                      final matchesStatus = _statusFilter == nul || a.status == _statusFilter;
                      final matchesStatus = _search.isEmpty || a.title.toLowerCase().contains(_search,toLowerCase());
                      return matchesStatus && matchesStatus;
                     }).toList();

                     return Scaffold(
                      appBar: AppBar(title: const Text('Dashaboard')),
                      body: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          childern: [
                              Row(
                                mainAxisAlignment: mainAxisAlignment.spaceEvenly,
                                childern: [
                                  _statusCountCard('To Do', TodoCount, Colors.orange),
                                  _statusCountCard('In Progress', inProgressCount, Colors.blue),
                                  _statusCountCard('Completed', completedCount, Colors.green),
                                ],
                              ),

                              const SizedBox(height: 16),
                              //Pie chart

                              SizedBox(
                                height: 160,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: TodoCount.toDouble(),
                                        color: Colors.orange,
                                        title: 'To Do',
                                      ),

                                      PieChartSectionData(
                                        value: inProgressCount.toDouble(),
                                        color: Colors.blue,
                                        title: 'In Progress',
                                      ),

                                      PieChartSectionData(
                                        value: completedCount.toDouble(),
                                        color: Colors.green,
                                        title: 'Completed',
                                      ),
                                    ],
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 30,                                    
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                                      
                              Row(
                              children: [
                                DropdownButton<AssignmentStatus?>(
                                  value: _statusFilter,
                                     hint: const Text('Filter by Status'),
                                     items: [
                                       const DropdownMenuItem(value: null, child: Text('All')),
                                         ...AssignmentStatus.values.map((status) => DropdownMenuItem(
                                           value: status,
                                              child: Text(status.toString().split('.').last),
                                            )),
                                       ],
                                       onChanged: (val) => setState(() => _statusFilter = val),
                                         ),
                                         const SizedBox(width: 16),
                                         Expanded(
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            hintText: 'Search by title or subject',
                                                   prefixIcon: Icon(Icons.search),
                                                 ),
                                           onChanged: (val) => setState(() => _search = val),
                                         ),
                                       ),
                                     ],
                                   ),
                            const SizedBox(height: 8),
                                Expanded(
                                  child: filtered.isEmpty
                                      ? const Center(child: Text('No assignments found.'))
                                      : ListView.builder(
                                          itemCount: filtered.length,
                                          itemBuilder: (context, idx) {
                                            final a = filtered[idx];
                                            return Card(
                                              child: ListTile(
                                                  title: Text(a.title),
                                                  subtitle: Text(a.subject),
                                                  onTap: () => widget.onAssignmentTap(a, widget.assignments.indexOf(a)),
                                                ),
                                              );
                                            },
                                          ),  
                                        ),
                                     ],
                                   ),
                                 ),
                                );
                               } 

                                    Widget _statusCountCard(String label, int count, Color color) {
                                      return Card(
                                        color: color.withOpacity(0.1),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                                          child: Column(
                                            childern: [
                                              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                              Text('$count', style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  }

                                  actions: [
                                    IconButton(
                                      icon: const Icon(Icons.dashboard),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DashboardPage(
                                              assignments: _assignments,
                                              onAssignmentTap: (a, idx) => _showAssignmentDetail(a, idx),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],


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

                    Future<void> _promptForImageAndComplete(Assignment assignment) async{
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() {
                          assignment.status = AssignmentStatus.Completed;
                          assignment.completionDate = DateTime.now();
                          assignment.imagePath = picked.path;
                        });
                        await _saveAssignments();
                      }
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
                          height: kanbanHeight,
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
                                               _promptForImageAndComplete(assignment);
                                               return;
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
                                                    trailing: assignment.status == AssignmentStatus.Completed && assignment.imagePath != null ? Image.file(
                                                      File(assignment.imagePath!),
                                                      width: 40,
                                                      height: 40,
                                                      errorBuilder: (context, error, stackTrace) => const Iocn(Icons.broken_image),) ; null,
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


                                          Widget _buildSubjectField() {
                                            return DropdownButtonFormField<String>(
                                              value: _subjectController.text.isNotEmpty ?_subjectController.text : null,
                                              items: getAllSubjects().map((subject) {
                                                return DropdownMenuItem(value: subject, child: Text(subject));
                                              }).toList(),
                                              onChanged: (val) {
                                                setState(() {
                                                  _subjectController.text = val ?? '';
                                                });
                                              },
                                              decoration: const InputDecoration(labelText: 'Subject Name'),
                                            );
                                          }


                                          Widget _buildAddSubjectButton(BuildContext context) {
                                            return TextButton(
                                              onPressed: () async {
                                                final newSubject = await showDialog<String>(
                                                  context: context,
                                                  builder: (context) {
                                                    final controller: TextEditingController();
                                                    return AlertDialog(
                                                      title:  const Text('Add Subject'),
                                                      context: TextField(
                                                        controller: controller,
                                                        decoration: const InputDecoration(labelText: 'Subject Name'),
                                                      ),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                                        TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add')),
                                                      ],
                                                    );
                                                  },
                                                );

                                                if (newSubject != null && newSubject.trim().isNotEmpty) {
                                                  setState(() {
                                                    addSubject(newSubject.trim());
                                                    _subjectController.text = newSubject.trim();
                                                  });
                                                }
                                              },
                                              child: const Text('Add Subject'),
                                            );
                                          }


                                          Widget _buildTeacherField() {
                                            return DropdownButtonFormField<String>(
                                              value: _submitToController.text.isNotEmpty ? _submitToController.text : null,
                                              items: getAllTeachers().map((teacher) {
                                                return DropdownMenuItem(value: teacher, child: Text(teacher));
                                              }).toList(),
                                              onChanged: (val) {
                                                setState(() {
                                                  _subjectToController.text = val ?? '';
                                                });
                                              },
                                              decoration: const InputDecoration(labelText: 'Submit To (Teacher)'),
                                            );
                                          }


                                          Widget _buildAddTeacherButton(BuildContext context) {
                                            return TextButton(
                                              onPressed: () async {
                                                final newTeacher = await showDialog<String>(
                                                  context: context,
                                                  builder: (context) {
                                                    final controller = TextEditingController();
                                                    return AlterDialog(
                                                      title: const Text('Add Teacher'),
                                                      content: TextField(
                                                        controller: controller,
                                                        decoration: const InputDecoration(labelText: 'Teacher Nmae'),
                                                      ),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                                        TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add')),
                                                      ],
                                                    );
                                                  },
                                                );

                                                if (newTeacher != null && newTeacher.trim().isNotEmpty) {
                                                  setState(() {
                                                    addTeacher(newTeacher.trim());
                                                    _submitToController.text = newTeacher.trim();
                                                  });
                                                }
                                              },
                                              child: const Text('Add Teacher'),
                                            )
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

