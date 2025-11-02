import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';


void main() {
    runApp(const MyApp());
}

enum AssignmentStatus {Todo, InProgress, Completed}
enum Priority {Low, Medium, High, Urgent}

//1. Enums for subjects and teacher
enum SubjectName {
    English,
    Mathematics,
    Physics,
    Chemistry,
    Nepali, 
    ComputerOrganiztoinAndArchitecture,
    OperatingSystem,
    JavaProgramming,
    WebAndMobileApplicationDevelopment,
}

enum TeacherName {
    MrManojSapkota,
    MrSushatAdhikari,
    MrMachaKaji,
    MrSurendraKhadka,
    MrPramondAcharya,
    MsSantoshiThokar,
    MsRejaThapa,
    MsMalikaJoshi,
    MsGeetaKhatri,
}



//2. Dynamic lists for  subjects and teachers
List<String> dynamicSubjects = [];
List<String> dynamicTeachers = [];

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
    Priority priority;
    Duration? timeSpent;
    DateTime? timerStartTime;

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
        this.priority = Priority.Medium,
        this.timeSpent,
        this.timerStartTime,
    });

    void startTimer() => timerStartTime = DateTime.now();

    void stopTimer() {
        if (timerStartTime != null) {
            timeSpent = (timeSpent ?? Duration.zero) + DateTime.now().difference(timerStartTime!);
            timerStartTime = null;
        }
    }

    factory Assignment.fromJson(Map<String, dynamic> json) {
        return Assignment(
            subject: json['subject'],
            title: json['title'],
            description: json['description'],
            deadline: DateTime.parse(json['deadline']),
            submitTo: json['submitTo'],
            status: AssignmentStatus.values[json['status'] ?? 0],
            startDate: json['StartDate'] != null ? DateTime.tryParse(json['startDate']) : null,
            completionDate: json['completionDate'] != null ? DateTime.tryParse(json['completionDate']) : null,
            imagePath: json['imagePath'], 
            priority: Priority.values[json['priority'] ?? 1],
            timeSpent: json['timeSpent'] != null ? Duration(microseconds: json['timeSpent']) : null,      
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
        'priority': priority.index,
        'timeSpent': timeSpent?.inMicroseconds,
    };    
}


//3. For Notifications and Reminders 


class NotificationService {
    static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

    static Future<void> initialize() async {
        const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
        const InitializationSettings settings = InitializationSettings(android: androidSettings);
        await _notifications.initialize(settings);
    }

    static Future<void> scheduleAssignmentReminder(Assignment assignment) async {
        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
            'assignment_channel',
            'Assignment  Reminders',
            importance: Importance.high,
        );

        const NotificationDetails details = NotificationDetails(android: androidDetails);

        await _notifications.show(
            assignment.hashCode,
            'ASSIGNMENT DUE SOON!!!!!',
            '${assignment.title} is due on ${assignment.deadline.toLocal().toString().split(' ')[0]}', details,
        );
    }
}



//4. For Exporting and Importing of Data 


class ExportService {
    static Future<void> exportToCSV(List<Assignment> assignments) async {
        final csvData = StringBuffer();
        csvData.writeln('Subject, Title, Description, Deadline, Status, Priority, Timespent');

        for (var assignment in assignments) {
            csvData.writeln('${assignment.subject}, ${assignment.title}.'
            '${assignment.description}, ${assignment.deadline.toIso8601String()},'
            '${assignment.status}, ${assignment.priority}, ${assignment.timeSpent?.inMinutes ?? 0}'
            );
        }

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/assignments_${DateTime.now().millisecondsSinceEpoch}.csv');
        await file.writeAsString(csvData.toString());

        await Share.shareFiles([(file.path)]);
    }

    static Future<List<Assignment>> importFromCSV() async {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['csv'],
        );


        if (result != null) {
            final file = File(result.files.single.path!);
            final csvData = await file.readAsString();
            return _parseCSVData(csvData);
        }
        return [];
    }


    static List<Assignment> _parseCSVData(String csvData) {
        final lines =  csvData.split('\n');
        final assignments = <Assignment>[];

        for (int i = 1; i < lines.length; i++) {
            final line = lines[i].trim();
            if (line.isEmpty) continue;

            final values = line.split('.');
            if (values.length >= 6) {
                assignments.add(Assignment(
                    subject: values[0],
                    title: values[1],
                    description: values[2],
                    deadline: DateTime.parse(values[3]),
                    submitTo: '',
                    status: AssignmentStatus.Todo,
                    priority: Priority.values.firstWhere((p) => p.toString().contains(values[5]), orElse: () => Priority.Medium),
                ));
            }
        }
        return assignments;
    }
}


//5 Theme Serivce


class ThemeService with ChangeNotifier {

            bool _isDarkMode = false;

            bool get isDarkMode => _isDarkMode;

            ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

            void toggleTheme() {
                _isDarkMode = !_isDarkMode;
                notifyListeners();
            }

            static final ThemeData _lightTheme = ThemeData.light();
            static final ThemeData _darkTheme = ThemeData.dark().copyWith(
                scaffoldBackgroundColor: Colors.grey[900],
                cardColor: Colors.grey[800],
            );           
        }


//6. Helper function for subjects and Teachers

String prettifyEnumName(String name) {
    final withSpaces = name.replaceAllMapped(RegExp(r'([A-Z])'), (m) => '${m[1]}');
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
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
        ...dynamicTeachers,
    ];
}


void addSubject(String subject) {
    if (!dynamicSubjects.contains(subject)) {
        dynamicSubjects.add(subject);
    }
}


void addTeacher(String teacher) {
    if (!dynamicTeachers.contains(teacher)) {
        dynamicTeachers.add(teacher);
    }
}


String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
}

Color _getPriorityColor(Priority priority) {
    switch (priority) {
        case Priority.Low: return Colors.green;
        case Priority.Medium: return Colors.orange;
        case Priority.High: return Colors.red;
        case Priority.Urgent: return Colors.deepPurple;
    }
}


//7. Main Part with Theme Support

class MyApp extends StatefulWidget {
    const MyApp({super.key});

    @override
    State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    final ThemeService _themeService = ThemeService();

        @override   
        void initState() {
            super.initState();
            _themeService.addListener(() {
                setState(() {});
            });
        }

        @override 
        void dispose() {
            _themeService.removeListener(() {});
            super.dispose();
        }

        @override
        Widget build(BuildContext content) {
            return MaterialApp(
                title: 'Assignment Manager',
                theme: ThemeData.light(),
                darkTheme: ThemeData.dark(),
                themeMode: _themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                home: AssignmentManager(themeService: _themeService),
                debugShowCheckedModeBanner: false,
            );
        }
}



//8. Core part of the Assingment manager

class AssignmentManager extends StatefulWidget {
    final ThemeService themeService;

    const AssignmentManager({super.key, required this.themeService});

    @override
    State<AssignmentManager> createState() => _AssignmentManagerState();
}

class _AssignmentManagerState extends State<AssignmentManager> {
    final List<Assignment> _assignments = [];

    @override
    void initState() {
        super.initState();
        _loadAssignments();
        NotificationService.initialize();


        widget.themeService.addListener(_onThemeChanged);
    }


    @override
    void dispose() {
        widget.themeService.removeListener(_onThemeChanged);
        super.dispose();
    }

    void _onThemeChanged() {
        setState(() {});
    }

    Future<void> _loadAssignments() async {
        final prefs = await SharedPreferences.getInstance();
        final data = prefs.getStringList('Assignments') ?? [];
        setState(() {
            _assignments.clear();
            _assignments.addAll(data.map((e) => Assignment.fromJson(jsonDecode(e))));
        });
    }

    Future<void> _saveAssignment() async {
        final prefs = await SharedPreferences.getInstance();
        final data = _assignments.map((a) => jsonEncode(a.toJson())).toList();
        await prefs.setStringList('assignments', data);
    }

    void _addOrEditAssignment({Assignment? assignment, int? index}) async {
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
                    NotificationService.scheduleAssignmentReminder(result);
                }
            });
            await _saveAssignment();
        }
    }

    void _removeAssignment(int index) async {
        setState(() {
            _assignments.removeAt(index);
        });
        await _saveAssignment();
    }


    void _showAssignmentDetail(Assignment assignment, int index) {
        Navigator.push(
        context,
        MaterialPageRoute(
            builder:  (context) => AssignmentDetail(
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

Future<void> _promptForImageAndComplete(Assignment assignment) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
        setState(() {
            assignment.status = AssignmentStatus.Completed;
            assignment.completionDate = DateTime.now();
            assignment.imagePath = picked.path;
        });
        await _saveAssignment();
    }
}



//9. Kanban Board with Drag and Drop 

Widget buildKanbanBoard() {
    Map<AssignmentStatus, List<Assignment>> statusMap = {
        AssignmentStatus.Todo: [],
        AssignmentStatus.InProgress: [],
        AssignmentStatus.Completed: [],
    };

    for (var a in _assignments) {
        statusMap[a.status]?.add(a);
    }

    final double KanbanHeight = (MediaQuery.of(context).size.height - kToolbarHeight - 100).clamp(200.0, double.infinity);

    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
                height: KanbanHeight,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AssignmentStatus.values.map((status) {
                        return SizedBox(
                            width: 260,
                            child: DragTarget<Assignment>(
                                onWillAccept: (assignment) {
                                    if (assignment == null) return false;
                                    if (status == AssignmentStatus.InProgress && assignment.status == AssignmentStatus.Todo) return true;
                                    if (status == AssignmentStatus.Completed && assignment.status == AssignmentStatus.InProgress) return true;
                                    return false;
                                },
                                onAccept: (assignment) async {
                                    SchedulerBinding.instance.addPostFrameCallback((_) async {
                                        setState(() {
                                            final index = _assignments.indexOf(assignment);
                                            if (index != -1) {
                                                if (status == AssignmentStatus.InProgress && assignment.status == AssignmentStatus.InProgress) {
                                                    assignment.status = AssignmentStatus.InProgress;
                                                    assignment.startDate = DateTime.now();
                                                } else if (status == AssignmentStatus.Completed && assignment.status == AssignmentStatus.InProgress) {
                                                    _promptForImageAndComplete(assignment);
                                                    return;
                                                }
                                                _assignments[index] = assignment;
                                            }
                                        });
                                        await _saveAssignment();
                                    });
                                },

                                builder: (context, candidateDate, rejectionData) => Card(
                                    margin: const EdgeInsets.all(8),
                                    child: Column(
                                        children: [
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
                                                        color: status == AssignmentStatus.Todo ? Colors.orange :
                                                        status == AssignmentStatus.InProgress ? Colors.blue : 
                                                        Colors.green,
                                                        letterSpacing: 1.2,                                                    
                                                    ),
                                                ),
                                            ),
                                            if (candidateDate.isNotEmpty)
                                            Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text(
                                                    "Drop Here",
                                                    style: TextStyle(color: Colors.blue),
                                                ),
                                            ),

                                            Expanded(
                                                child: ListView.builder(
                                                    itemCount: statusMap[status]!.length,
                                                    itemBuilder: (context, index) {
                                                        final assignment = statusMap[status]![index];

                                                        return Draggable<Assignment>(
                                                            data: assignment,
                                                            feedback: SizedBox(
                                                                width: 240,
                                                                child: Card(
                                                                    child: ListTile(
                                                                        title: Text(
                                                                            assignment.title,
                                                                            style: const TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 16,
                                                                                color: Colors.black87,
                                                                            ),
                                                                            maxLines: 1,
                                                                            overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                        subtitle: Text(
                                                                            assignment.subject,
                                                                            style: const TextStyle(
                                                                                fontSize: 13,
                                                                                color: Colors.black54,
                                                                                fontStyle: FontStyle.italic,
                                                                            ),
                                                                            maxLines: 1,
                                                                            overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                    ),
                                                                ),
                                                            ),

                                                            child: ListTile(
                                                                title: Text(
                                                                    assignment.title,
                                                                    style: const TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 16,
                                                                        color: Colors.black87,
                                                                    ),
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                    subtitle: Text(
                                                                        assignment.subject,
                                                                        style: const TextStyle(
                                                                            fontSize: 13,
                                                                            color: Colors.black54,
                                                                            fontStyle: FontStyle.italic,
                                                                        ),
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                        trailing: assignment.status == AssignmentStatus.Completed && assignment.imagePath != null ? Image.file(
                                                                            File(assignment.imagePath!),
                                                                            width: 40,
                                                                            height: 40,
                                                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                                                        )
                                                                        :null,
                                                                        onTap: () => _showAssignmentDetail(
                                                                            assignment,
                                                                            _assignments.indexOf(assignment),
                                                                        ),
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


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('ASsignment Manager'),
                actions: [
                    //Buttons for Dashboard
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

                    //Button for Calendar
                    IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => CalendarPage(assignments: _assignments),
                                ),
                            );
                        },
                    ),

                    //Button for Anayltics 
                    IconButton(
                        icon: const Icon(Icons.analytics),
                        onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AnalyticsPage(assignments: _assignments),
                                ),
                            );
                        },
                    ),

                    //Button for Export/Import
                    IconButton(
                        icon: const Icon(Icons.import_export),
                        onPressed: () => _showExportMenu(context),
                    ),

                    //Button for Theme Toggeling
                    IconButton(
                        icon: Icon(widget.themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                        onPressed: () {
                            widget.themeService.toggleTheme();
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
                        Expanded(child: buildKanbanBoard()),
                    ],
                ),
            ),
        );
    }



    void _showExportMenu(BuildContext context) {
        showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        ListTile(
                            leading: const Icon(Icons.upload),
                            title: const Text('Export to CSV'),
                            onTap: () {
                                Navigator.pop(context);
                                ExportService.exportToCSV(_assignments);
                            },
                        ),
                        ListTile(
                            leading: const Icon(Icons.download),
                            title: const Text('Import from CSV'),
                            onTap: () async {
                                Navigator.pop(context);
                                final imported = await ExportService.importFromCSV();
                                if (imported.isNotEmpty) {
                                    setState(() {
                                        _assignments.addAll(imported);
                                    });
                                    await _saveAssignment();
                                    }
                                 },
                              ),
                           ],
                        ),    
                     );
                  }
               }


 //10. Assignment Form with Teachrs and Subjects
class AssignmentForm extends StatefulWidget {
    final Assignment? assignment;
    const AssignmentForm({super.key, this.assignment});

    @override
    State<AssignmentForm> createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
    final _formKey = GlobalKey<FormState>();
    late TextEditingController _subjectController;
    late TextEditingController _titleController;
    late TextEditingController _descriptionController;
    late TextEditingController _submitToController;
    DateTime? _deadline;
    Priority _priority = Priority.Medium;

    @override
    void initState() {
        super.initState();
        _subjectController = TextEditingController(text: widget.assignment?.subject ?? '');
        _titleController = TextEditingController(text: widget.assignment?.title ?? '');
        _descriptionController = TextEditingController(text: widget.assignment?.description ?? '');
        _submitToController = TextEditingController(text: widget.assignment?.submitTo ?? '');
        _deadline = widget.assignment?.deadline;
        _priority = widget.assignment?.priority ?? Priority.Medium;
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
        final picked = await  showDatePicker(
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
            value: _subjectController.text.isNotEmpty ? _subjectController.text : null,
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
                        final controller = TextEditingController();
                        return AlertDialog(
                            title: const Text('Add Subject'),
                            content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(labelText: 'Subject Name'),
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

                if (newSubject != null && newSubject.trim().isNotEmpty) {
                    setState(() {
                        addSubject(newSubject.trim());
                        _subjectController.text = newSubject.trim();
                    });
                }
            },
            child: const Text('ADD Subject'),
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
                    _submitToController.text = val ?? '';
                });
            },
            decoration: const InputDecoration(labelText: 'Submit TO TEahcer'),
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
                            title: const Text('Add teacher'),
                            content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(labelText: 'Teacher Name'),
                            ),
                            actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
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
            child: const Text('Add Teacher'),
        );
    }



    Widget _buildPriorityField() {
        return DropdownButtonFormField<Priority>(
            value: _priority,
            items: Priority.values.map((priority) {
                return DropdownMenuItem(
                    value: priority,
                    child: Row(
                        children: [
                            Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                    color: _getPriorityColor(priority),
                                    shape: BoxShape.circle,
                                ),
                            ),
                            const SizedBox(width: 8),
                            Text(priority.toString().split('.').last),
                        ],
                    ),
                );
            }).toList(),
            onChanged: (val) {
                setState(() {
                    _priority = val ?? Priority.Medium;
                });
            },
            decoration: const InputDecoration(labelText: 'Priority'),
        );
    }

    @override
    Widget build(BuildContext context) {
                   return Scaffold(
                appBar: AppBar(
                    title: Text(widget.assignment == null ? 'Add Assignment' : 'Edit Asignment'),
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
                                    decoration: const InputDecoration(labelText: 'Assignment Title'),
                                    validator: (value) => value!.isEmpty? 'Enter Title' : null,
                                ),

                                TextFormField(
                                    controller: _descriptionController,
                                    decoration: const InputDecoration(labelText: 'Description'),
                                    maxLines: 3,
                                    validator: (value) => value!.isEmpty? 'Enter Description' : null,
                                ),

                                _buildTeacherField(),
                                _buildAddTeacherButton(context),
                                _buildPriorityField(),

                                const SizedBox(height: 10),
                                ListTile(
                                    title: Text(
                                        _deadline == null ? 'Pick Deadline' : 'Deadline: ${_deadline!.toLocal().toString().split('.')[0]}',
                                    ),
                                    trailing: const Icon(Icons.calendar_today),
                                    onTap: _pickDeadline,
                                ),
                                if (_deadline == null)
                                const Padding(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: Text(
                                            'Please Select a deadline',
                                            style: TextStyle(color: Colors.red),
                                    ),
                                ),
                                const SizedBox(height: 20),
                               ElevatedButton(
                                  onPressed: _save,  
                                  child: Text(widget.assignment == null ? 'ADD' : 'UPDATE'),
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
                    priority: _priority,
                );
                Navigator.pop(context, assignment);
            }
        }
    }

//11. Assignment Detial with Timer
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


            Widget _buildTimerControls(Assignment assignment) {
                return Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Text(
                                    'Time Tracking',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                    children: [
                                        IconButton(
                                            icon: Icon(assignment.timerStartTime == null ? Icons.play_arrow : Icons.stop),
                                            onPressed: () {
                                                if (assignment.timerStartTime == null) {
                                                    assignment.startTimer();
                                                } else {
                                                    assignment.stopTimer();
                                                }
                                            },
                                        ),
                                        Text('Time spent: ${_formatDuration(assignment.timeSpent ?? Duration.zero)}'),
                                    ],
                                ),
                            ],
                        ),
                    ),
                );
            }

            @override
            Widget build(BuildContext context) {
                return Scaffold(
                    appBar: AppBar(
                        title: Text(assignment.title),
                        actions: [
                            IconButton(icon: const Icon(Icons.edit), onPressed: onDelete),
                        ],
                    ),

                    body: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                            children: [
                                ListTile(title: const Text('Subject'), subtitle: Text(assignment.subject)),
                                ListTile(title: const Text('Title'), subtitle: Text(assignment.title)),
                                ListTile(title: const Text('Description'), subtitle: Text(assignment.description)),
                                ListTile(title: const Text('Deadline'), subtitle: Text(assignment.deadline.toLocal().toString().split('')[0]),),
                                ListTile(title: const Text('Submit To'), subtitle: Text(assignment.submitTo)),
                                ListTile(title: const Text('Priority'), subtitle: Row(
                                    children: [
                                        Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                                color: _getPriorityColor(assignment.priority),
                                                shape: BoxShape.circle,
                                            ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(assignment.priority.toString().split('.').last),
                                    ],
                                ),
                             ),

                             if (assignment.status == AssignmentStatus.InProgress) _buildTimerControls(assignment),
                             if (assignment.status == AssignmentStatus.Completed) ...[
                                
                                if (assignment.startDate != null)
                                ListTile(
                                    title: const Text('Started Date'),
                                    subtitle: Text(assignment.startDate!.toLocal().toString().split('')[0]),
                                ),

                                if (assignment.completionDate != null)
                                ListTile( 
                                    title: const Text('Completed Date'),
                                    subtitle: Text(assignment.completionDate!.toLocal().toString().split('')[0]),
                                ),

                                if (assignment.imagePath != null) 
                                Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            const Text('Assignment Image', style: TextStyle(fontWeight: FontWeight.bold),),
                                            
                                            const SizedBox(height: 8),
                                            Image.file(
                                                File(assignment.imagePath!),
                                                height: 100,
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


//12. Dashboard Page
 class DashboardPage extends StatefulWidget {
    final List<Assignment> assignments;
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
        final todoCount = widget.assignments.where((a) => a.status == AssignmentStatus.Todo).length;
        final inProgressCount = widget.assignments.where((a) => a.status == AssignmentStatus.InProgress).length;
        final completedCount = widget.assignments.where((a) => a.status == AssignmentStatus.Completed).length;
        final filtered = widget.assignments.where((a) {
            final matchesStatus = _statusFilter == null || 
            a.status == _statusFilter;
            final matchesSearch = _search.isEmpty ||
            a.title.toLowerCase().contains(_search.toLowerCase()) ||
            a.subject.toLowerCase().contains(_search.toLowerCase());
            return matchesStatus && matchesSearch;
        }).toList();


        return Scaffold(
            appBar: AppBar(title: const Text('Dashboard')),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                                _statusCountCard('To Do', todoCount, Colors.orange),
                                _statusCountCard('In Progress', inProgressCount, Colors.blue),
                                _statusCountCard('Completed', completedCount, Colors.green),
                            ],
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                            height: 160,
                            child: PieChart(
                                PieChartData(
                                    sections: [

                                        PieChartSectionData(
                                                value: todoCount.toDouble(),
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
                                        ...AssignmentStatus.values.map(
                                          (status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status.toString().split('.').last),
                                          ),
                                        ),
                                      ],
                                      onChanged: (val) => setState(() => _statusFilter = val),
                                    ),
                                const SizedBox(width:16),
                                Expanded(
                                    child: TextField(
                                        decoration: const InputDecoration(
                                            hintText: "Search by title or subject",
                                            prefixIcon: Icon(Icons.search),
                                        ),
                                        onChanged: (val) => setState(() => _search = val),
                                    ),
                                ),
                            ],
                        ),

                        const SizedBox(height: 8),
                        Expanded(
                            child: filtered.isEmpty ? const Center(child: Text('No assignmets found.')) : ListView.builder(
                                itemCount:filtered.length,
                                itemBuilder: (context, idx) {
                                    final a = filtered[idx];
                                    return Card(
                                        child: ListTile(
                                            title: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Text(
                                                        a.title,
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Colors.black87,
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
                                            trailing: a.status == AssignmentStatus.Completed && a.imagePath != null 
                                                ? Image.file(
                                                    File(a.imagePath!), 
                                                    width: 40,
                                                    height: 40,
                                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                                                  )
                                                : null,
                                            onTap: () => widget.onAssignmentTap(a, widget.assignments.indexOf(a),),
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
                    children: [
                        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold),),
                        Text('$count', style: TextStyle(
                            fontSize: 30,
                            color: color,
                            fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                ),
            ),
        );
    }
 }


//13. Calender Page Feature
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

        return assignmentsMap;
    }


    @override
    Widget build(BuildContext context) {
        final assignmentsByDay = _getAssignmentsByDay();

        return Scaffold(
            appBar: AppBar(title: const Text('Calendar View')),
            body: TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                eventLoader: (day) => assignmentsByDay[day] ?? [],
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


//14. Analytics Page

class AnalyticsPage extends StatelessWidget {
    final List<Assignment> assignments;

    const AnalyticsPage({super.key, required this.assignments});

    Duration _calculateAverageCompletionTime() {
        final completedAssignments = assignments.where((a) => a.status == AssignmentStatus.Completed && a.startDate != null && a.completionDate != null).toList();

        if (completedAssignments.isEmpty) return Duration.zero;

        final totalDuration = completedAssignments.fold<Duration>(
            Duration.zero,
            (prev, a) => prev + a.completionDate!.difference(a.startDate!)
        );

        return Duration(
            microseconds: totalDuration.inMicroseconds ~/ completedAssignments.length
        );
    }

    String _findMostProductiveDay() {
        final completedByDay = <String, int>{};

        for (var assignment in assignments.where((a) => a.completionDate != null)) {
            final day = assignment.completionDate!.weekday;
            completedByDay[day.toString()] = (completedByDay[day.toString()] ?? 0) + 1;
        }

        if (completedByDay.isEmpty) return 'No Data';

        final mostProductive = completedByDay.entries.reduce((a,b) => a.value > b.value ? a:b);
        final days = ['Monday', 'Tuesday', 'Wednesday', 'Thrusday', 'Friday', 'Saturday', 'Sunday'];
        return days[int.parse(mostProductive.key) - 1];
    }

    
    Widget _buildStatCard(String label, String value) {
        return Card(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    children: [
                        Text(
                            label, 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            value,
                            style: const TextStyle(fontSize: 24, color: Colors.blue),
                        ),
                    ],
                ),
            ),
        );
    }


    Widget _buildSubjectDistributionChart() {
        final subjectCounts = <String, int>{};
        for (var assignment in assignments) {
            subjectCounts[assignment.subject] = (subjectCounts[assignment.subject] ?? 0) + 1;
        }

        return Card(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text(
                            'Assignments by Subject',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ...subjectCounts.entries.map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                                children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text(entry.key),
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: LinearProgressIndicator(
                                            value: entry.value / assignments.length,
                                            backgroundColor: Colors.grey[300],
                                        ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${entry.value}'),
                                ],
                            ),
                        )),
                    ],
                ),
            ),
        );
    }


    @override
    Widget build(BuildContext context) {
        final completedThisWeek = assignments.where((a) => 
        a.completionDate != null && 
        a.completionDate!.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length;

        final averageCompletionTime = _calculateAverageCompletionTime();
        final mostProductiveDay = _findMostProductiveDay();

        return Scaffold(
            appBar: AppBar(title: const Text('Analytics')),
            body: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                    _buildStatCard('Completed This Week', '$completedThisWeek assignments'),
                    _buildStatCard('Average Completion Time', '${averageCompletionTime.inHours}h ${averageCompletionTime.inMinutes.remainder(60)}m'),
                    _buildStatCard('Most Productive Day', mostProductiveDay),
                    _buildStatCard('Total Assignments', '${assignments.length}'),
                    const SizedBox(height: 16),
                    _buildSubjectDistributionChart(),
                ],
            ),
        );
    }
}





