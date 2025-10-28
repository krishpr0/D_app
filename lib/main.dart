import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';


void main() {
  runApp(const MyApp());
}

enum AssignmentStatus { Todo, InProgress, Completed }


//1.enums for common subjects and teachers
enum SubjectName {
  English,
  Mathematics,
  Nepali,  
  DigitalDesignAndMicroprocessor,
  OperatingSystem,
  WebAndMobileApplicationDevelopment,
  JavaProgramming,
  Chemistry,
  Physics,
} 

enum TeacherName {
  MrSushatAdhikari,
  MrMachaKajiMaharjan,
  MrSurendraKhadka,
  MrParmodAcharya,
  MrManojSapkota,
  MsRejaThapa,
  MsMalikaJoshi,
  MsSantoshiThokar,
  MsGeetaKhatriz
}

//2. Dynamic lists for user-added subjects and teachers

List<String> dynamicSubjects = [];
List<String> dyanmicTeachers = [];

class Assignment {
  String subject;
  String title;
  String description;
  DateTime deadline;
  String submitTo;
  AssignmentStatus status;
  DataTime? startDate;
  DateTime? completionDate;
  String? imagePath;

  Assignment({
    required this.subject,
    required this.title,
    required this.description,
    required this.deadline,
    required this.submitTo,
    this.status = AssignmentStatus.Todo,
    this.startDate,
    this.completionDate,
    this.imagePath,
  });


  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      subject: json['subject'],
      title: json['title'],
      description: json['description'],
      deadline: DateTime.parse(json['deadline']),
      submitTo: json['submitTo'],
      status: AssignmentStatus.values[json['status']],
      startDate: json['startDate'] != null ? 
      DateTime.tryParse(json['startDate']) : null,
      completionDate: json['completionDate'] != null ? 
      DateTime.tryParse(json['completionDate']) : null,
      imagePath: json['imagePath'],
    );
  }

  
  Map<String, dynamic> toJson() => {
    'subject': subject,
    'title': title,
    'description': description,
    'deadline': deadline.toIso8601String(),
    'submitTo': submitTo,
    'status': status.index,
    'startDate': startDate?.toIso8601String(),
    'completionDate': completionDate?.toIso8601String(),
    'imagePath': imagePath,
  };
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assignment Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //scaffoldBackgroundColor: Colors.black,
        //brightness: Brightness.dark,
      ),
      home: const AssignmentManager(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AssignmentManager extends statefulWidget {
  const AssignmentManager({super.key});

  @override
  State<AssignmentManager> createState() => _AssignmentManagerState();
}

class _AssignmentManagerState extends State<AssignmentManager> {
  final List<Assignment> _assignments = [];


  @override 
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    final prefs = await SharedPrefernces.getInstance();
    final data = prefs.getStringList('assignments') ?? [];
    setState(() {
      _assignments.clear();
      _assignments.addAll(data.map((e) => Assignment.fromJson(jsonDecode(e))));
    });
  }


  Future<void> _saveAssignments() async {
    final prefs = await SharedPrefernces.getInstance();
    final data = _assignments.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('assignments', data);
  }


  void _addOrEditAssignment({Assignment? assignment, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignmentForm(
          assignment: assignment),
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
          onDelete: () {
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


    final double kanbanHeight = (MediaQuery.of(context).size.height - kToolbarHeight - 100).clamp(
      200.0,
      double.infinity,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
        child: SizedBox(
          height: kanbanHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AssignmentStatus.values.map((status) {
              return SizedBox(
                width: 260,

                child: DragTarget<Assignment>(
                  onWillAccept: (assignment) {
                    if (assignment == null) return false;
                    if (status == AssignmentStatus.InProgress && assignment.status == AssignmentStatus.Todo)
                    return true;
                    if (status == AssignmentStatus.Completed && assignment.status == AssignmentStatus.InProgress)
                    return true;
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

                  builder: (context, candidateData, rejectedData) => Card(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          status
                          .toString()
                          .split('.')
                          .last
                          .replaceAllMapped(
                            RegExp(r'([A-Z])'),
                            (m) => ' ${m[1]}',
                          )
                          .toUpperCase(),
                          style: TextStyle(
                            fontWeight: fontWeight.bold,
                            fontSize: 18,
                            color: status == AssignmentStatus.Todo
                            ? Colors.orange
                            : status == AssignmentStatus.InProgress
                            ? Colors.blue
                            : Colors.green,

                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                        if (candidateData.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Drop here",
                            style: TextStyle(
                              color: Colors.blue,                              
                            ),
                          ),

                          Expanded(
                            child: ListView.builder(
                              itemCount: statusMap[status]!.length,
                              itemBuilder: (context, index) {
                                final assignment = statusMap[status]![index];
                                return Draggale<Assignment>(
                                  data: assignment,
                                  feedback: SizedBox(
                                    width: 240,
                                    child: Card(
                                      child: ListTile(
                                        title: Text(assignment.title, 
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.balck87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(assignment.subject,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          fontstyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  title: Text(assignment.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(assignment.subject,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => _showAssignmentDetail(assignment, _assignments.indexOf(assignment),
                                  ),
                                  trailing: 
                                  assignment.status == AssignmentStatus.Completed && assignment.imagePath != null ? Image.file(
                                    File(assignment.imagePath!),
                                    width: 40,
                                    height: 40,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                  ) 
                                  : null,
                                ),          
                            );
                          },
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


Future<void> _promptForImageAndComplete(Assignment assignment) async {
  final picker = ImagePicker();  
  final picked = await picerk.pickImage(source: ImageSource.gallery);

  if (picked != null) {
    setState(() {
      assignment.status = AssignmentStatus.Completed;
      assignment.completionDate = DateTime.now();
      assignment.imagePath = picked.path;
    });
    await _saveAssignments();
  }
}


@override
Widget build(BuildContext context) {
   return Scaffold(
    appBar: AppBar(
      title: const Text('Assignment Tracker'),
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
    ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _addOrEditAssignment(),
                  child: const Text('Add Assignment'),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: buildKanbanBoard()),              
              ],
            ),
          );
        }
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
              AssignmentStatus _status = AssignmentStatus.Todo;

              DateTime? _startDate;
              DateTime? _completionDate;
              String? _imagePath;

              @override 
              void initState() {
                super.initState();
                
                _subjectController = TextEditingController(
                  text: widget.assignment?.subject ?? '',
                );

                _titleController = TextEditingController(
                  text: widget.assignment?.title ?? '',
                );

                _descriptionController = TextEditingController(
                  text: widget.assignment?.description ?? '',
                );

                _submitToController = TextEditingController(
                  text: widget.assignment?.submitTo ?? '',
                );

                _deadline = widget.assignment?.deadline;
                _status = widget.assignment?.status ?? AssignmentStatus.Todo;
                _startDate = widget.assignment?.startDate;
                _completionDate = widget.assignment?.completionDate;
                _imagePath = widget.assignment?.imagePath;
              }

              @override
              void dispose() {
                _subjectController.dispose();
                _titleController.dispose();
                _descriptionController.dispose();
                _submitToController.dispose();
                super.dispose();
            }

            Future<void> _pickImage() async {
             final picker = ImagePicker();
             final picked = await picker.pickImage(source: ImageSource.gallery);

             if (picked != null) {
              setState(() {
                _imagePath = picked.path;
              });
             } 
            }


            Future<void> _pickDeadLine() async {
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

          Future<void> _pickStartDate() async {
            final now = DatteTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: _startDate ?? now,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 5),              
            );

            if (picked != null) {
              setState(() {
                _startDate = picked;
              });
            }
          }


          
            Future<void> _pickCompletionDate() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: _completionDate ?? now,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 5),
            };
            if (picked != null) {
              setState(() {
                _completionDate = picked;
              });
            }
          }

          //7 .Example usage in your AssignmentForm
          Widget _buildSubjectField() {
            return DropdownButtonFormField<String>(
              value: _subjectController.text.isNotEmpty
              ? _subjectController.text
              : null,
              
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

          //Button to add new subject
          Widget _buildAddSubjectButton(BuildContext context) {
            return TextButton(
              onPressed: () async {
                final newSubject = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    final controller = TextEditingController();
                    return AlterDialog(
                      title: const Text('Add New Subject'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Subject Name'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, controller.text),
                          child: const TExt('Add'),
                        ),
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
          child: const Text('Add New Subject'),
        );
      }

      //Reapeat similar for Teacher dropdown and add button

      Widget _buildTeacherField() {
        return DropdownButtonFormField<String>(
          value: _submitToController.text.isNotEmpty
          ? _submitToController.text : null,

          items: getAllTeachers().map((teacher) {
            return DropdownMenuItem(value: teacher, child: Text(teacher));
          }).toList(),

          onChanged: (val) {
            onState(() {
              _submitToController.text = val ?? '';
            });
          },
          decoration: const InputDecoration(labelText: 'Sumbit To (Teacher)'),
        );
      }


      Widget _buildAddTeacherButton(BuildContext context) {
        return TextButton(
          onPressed: () async {
            final newTeacher = await showDialog<String>(
              context: context,
              builder: (context) {
                final controller = TextEditingController();
                return AlertDialog(
                  title: const Text('Add Teacher'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Teacher Name'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, controller.text),
                      child: const Text('Add'),
                    ),
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
          child: const Text('Add New Teacher'),
        );
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.assignment == null ? 'Add Assignment' : 'Edit Assignment'
            ),
          ),

          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildSubjectField(),
                  _buildAddSubjectButton(context),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                      labelText: 'Assignment Title',
                      ),
                      validator: (value) => value!.isEmpty ? 'Enter Title' : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Enter Description' : null
                    ),
                    _buildTeacherField(),
                    _buildAddTeacherButton(context),
                    const SizedBox(height: 10),
                    ListTile(
                      title: Text(
                        _deadline == null ? 'PickDeadline' : 'Deadline: $(_deadline!.toLocal().toString().split('')[0]}',),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _pickDeadLine,
                      ),

                      if (_deadline == null)
                          const Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              "Please Select a deadline",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _save,
                            child: Text(widget.assignment == null ? 'Add' : 'update'),
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
                    status: AssignmentStatus.Todo, //Always todo on creation
                    starDate: null,
                    completionDate: null,
                    imagePath: null,
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
                        ListTile(
                          title: const Text('Subject'),
                          subtitle: Text(assignment.subject),
                        ),

                        ListTile(
                          title:const Text('Title'),
                          subtitle: Text(assignment.title),
                        ),

                        ListTile(
                          title:const Text('Description'),
                          subtitle: Text(assignment.description),
                        ),

                        ListTile(
                          title:const Text('Deadine'),
                          subtitle:Text(
                            assignment.description.toLocal().toString().split('')[0],),
                        ),
                        
                        ListTile(
                          title:const Text('Submit To'),
                          subtitle: Text(assignment.submitTo),
                        ),
                        
                        //Show stareted and completed data if assignment is completed
                        if (assignment.status == AssignmentStatus.Completed) ...[
                          if (assignment.startDate != null)
                          ListTile(
                            title: const Text('Started Date'),
                            subtitle: Text(
                              assignment.startDate!.toLocal().toString().split('')[0],
                            ),
                          ),
                          if (assignment.completionDate != null) 
                          ListTile(
                            title: const Text('Completion Date'),
                            subtitle: Text(
                              assignment.completionDate!.toLocal().toString().split('')[0],
                            ),
                          ),
                          if (assignment.imagePath != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Assignment Image:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold),
                                ),  
                                const SizedBox(height: 8),
                                Image.file(
                                  File(assignment.imagePath!),
                                  height: 180,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }
            }


            class DashboardPage extends StatefulWidget {
              final List<Assignment> assignments;
              final Function(Assignment, int) onAssignmentTap;

              const DashboardPage({
                super.key,
                required this.assignments,
                required this.onAssignmentTap,
              });
              
              @override 
              State<DashboardPage> createState*() => _DashboardPageState();
            }

            class _DashboardPageState extends State<DashboardPage> {
              AssignmentStatus?  _statusFilter;
              String _search = '';

              @override
              Widget build(BuildContext context) {
                //Counts

                final TodoCount = widget.assignments.where((a) => a.status == AssignmentStatus.Todo).length;
                final inProgressCount = widget.assignments.where((a) => a.status == AssignmentsStatus.InProgress).length;
                final completedCount = widget.assignments.where((a) => a.status == AssignmentsStatus.Completed).length;


                //Filtered List
                final filtered = widget.assignments.where((a) {
                  final matchedStatus = _statusFilter == null || a.status == _statusFilter;
                  final matchedStatus = 
                        _search.isEmpty ||
                        a.title.toLowerCase().constains(_search.toLowerCase()) || a.subject.toLowerCase().constains(_search.toLowerCase());
                  return matchedStatus && matchedSearch;
                }).toList();
              
                  return Scaffold(
                    appBar: AppBar(
                      body: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children[
                            //counts
                            Row(
                              mainAxisAlignment: mainAxisAlignment.spaceEvenly,
                              children: [
                                _statusCountCard('To Do', TodoCount, Colors.orange),
                                _statusCountCard('In Progress', inProgressCount, Colors.blue),
                                _statusCountCard('Completed', completedCount, Colors.green),
                              ],
                            ),

                            const SizedBox(height: 16),

                            //Pie Chart
                            SizedBox(
                              height: 160,
                              child: PieChart(
                                PieChartData(
                                  sections:[
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
                            //Filter and Search
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
                                        ),
                                        ),
                                      ],

                                      onChanged: (val) => setState(() => _statusFilter = val),
                                  ),

                                  const SizedBox(width: 16),
                                  Expanded(
                                    child; TextField(
                                      decoration: const InputDecoration(
                                        hintText: 'Search by title or subject',
                                        prefixIcon: Icons(Icons.search),
                                      ),
                                      onChanged: (val) => setState(() => _search = val),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            Expanded(
                              child: filtered.isEmpty ? const Center(child: Text('No assignmets found')) : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, idx) {
                                  final a = filtered[idx];
                                  return Card(
                                    child: ListTile(
                                      title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        childern: [
                                           Text(
                                            a.title,
                                            style: const TextStyle(
                                              fontWeight: Fontweight.bold,
                                              fontSize: 16,
                                              color: Colors.balck87,
                                            ),
                                           ),


                                           const SizedBox(height: 2),
                                           Text(
                                            a.subject,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                              fontStyle: FontStyle.italic,
                                            ),
                                           ),
                                        ],
                                      ),

                                      subtitle: Text(
                                        a.status.toString().split('.').last,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blueGrey,
                                        ),
                                      ),

                                      trailing:
                                      a.status == AssignmentStatus.Completed && a.imagePath != null 
                                      ? Image.file(
                                        File(a.imagePath!),
                                        width: 40,
                                        height: 40,
                                        errorBuilder:
                                        (context, error, stackTrace) => const Icon(Icons.broken_image),
                                        )
                                        :null,
                                        onTap: () => widget.onAssignmentTap(
                                          a,
                                          widget.assignments.indexOf(a),
                                        ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  )

                      Widget _statusCountCard(String label, int count, Color color) {
                        return Card(
                          color: color.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                            child: Column(
                              childern: [
                                Text(
                                  label,
                                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$count',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: color,
                                    Fontweight: Fontweight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    }
                        // 3. Helper to get all subjects (enum + dynamic)

                        String prettifyEnumName(String name) {
                          final withSpace = name.replaceAllMapped(
                            RegExp(r'([A-Z])'),
                            (m) => '${m[1]}',
                          );
                          return withSpace[0].toUpperCase() + withSpace.subString(1);
                        }


                        List<String> getAllSubjects() {
                          return [
                            ...SubjectName.values.map((e) => prettifyEnumName(e.name)),
                            ...dynamicSubjects,
                          ];
                        }

                        List<String> getAllTeachers() {
                          return [
                            ...TeacherName.values.map((e) => prettifyEnumName(e.name)),
                            ...dyanmicTeachers,
                          ];
                        }

                        void addSubject(String subject) {
                          if (!dynamicSubjects.contains(subject)) {
                            dynamicSubjects.add(subject);
                          }
                        }

                        void addTeacher(String teacher) {
                          if (!dyanmicTeachers.contains(teacher)) {
                            dyanmicTeachers.add(teacher);
                          }
                        }









      
