import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum CTType { none, ct1, ct2, ct3, ct4 }

extension CTTypeExtension on CTType {
  Color get color {
    switch (this) {
      case CTType.ct1:
        return Colors.red.shade100;
      case CTType.ct2:
        return Colors.green.shade100;
      case CTType.ct3:
        return Colors.orange.shade100;
      case CTType.ct4:
        return Colors.blue.shade100;
      case CTType.none:
        return Colors.transparent;
    }
  }

  String get displayName {
    switch (this) {
      case CTType.ct1:
        return 'CT1';
      case CTType.ct2:
        return 'CT2';
      case CTType.ct3:
        return 'CT3';
      case CTType.ct4:
        return 'CT4';
      case CTType.none:
        return '';
    }
  }
}

class Topic {
  String id;
  String name;
  bool isSelected;
  CTType ctType;
  DateTime createdAt;

  Topic({
    required this.id,
    required this.name,
    this.isSelected = false,
    this.ctType = CTType.none,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isSelected': isSelected,
    'ctType': ctType.index,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
    id: json['id'],
    name: json['name'],
    isSelected: json['isSelected'],
    ctType: CTType.values[json['ctType']],
    createdAt: DateTime.parse(json['createdAt']),
  );

  Topic copyWith({
    String? id,
    String? name,
    bool? isSelected,
    CTType? ctType,
    DateTime? createdAt,
  }) {
    return Topic(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
      ctType: ctType ?? this.ctType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Course {
  String id;
  String code;
  String name;
  List<Topic> topics;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.topics,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'topics': topics.map((t) => t.toJson()).toList(),
  };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'],
    code: json['code'],
    name: json['name'],
    topics: (json['topics'] as List).map((t) => Topic.fromJson(t)).toList(),
  );
}

class UserRole {
  static const String student = 'student';
  static const String cr = 'cr';
  static const String teacher = 'teacher';

  String role;

  UserRole({this.role = student});

  bool get canAddTopic => role == cr || role == teacher;
  bool get canDeleteTopic => role == cr || role == teacher;
  bool get canAddCourse => role == cr || role == teacher;
  bool get canDeleteCourse => role == cr || role == teacher;
  bool get canSelectCT => true;
}

class CurriculumData {
  static Map<String, Map<String, Map<String, List<Course>>>> data = {};

  static void initialize() {
    if (data.isNotEmpty) return;

    data['CSE'] = {
      '1st': {
        'Odd': [
          Course(
            id: 'cse_1st_odd_1',
            code: 'CSE 1101',
            name: 'Structured Programming',
            topics: [
              Topic(
                id: '1',
                name: 'Algorithm',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
              Topic(
                id: '2',
                name: 'Writing Programs',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
              Topic(
                id: '3',
                name: 'Debugging Programs',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
            ],
          ),
          Course(
            id: 'cse_1st_odd_2',
            code: 'CSE 1100',
            name: 'Computer Fundamentals and Ethics Sessional',
            topics: [
              Topic(
                id: '7',
                name: 'Computer Science as Discipline',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
              Topic(
                id: '8',
                name: 'Computer Engineering',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
            ],
          ),
        ],
        'Even': [
          Course(
            id: 'cse_1st_even_1',
            code: 'CSE 1201',
            name: 'Data Structure',
            topics: [
              Topic(
                id: '10',
                name: 'Linear Array',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
              Topic(
                id: '11',
                name: 'Stack',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
            ],
          ),
        ],
      },
      '2nd': {'Odd': [], 'Even': []},
      '3rd': {'Odd': [], 'Even': []},
      '4th': {'Odd': [], 'Even': []},
    };

    data['EEE'] = {
      '1st': {
        'Odd': [
          Course(
            id: 'eee_1st_odd_1',
            code: 'EEE 1101',
            name: 'Basic Electrical Engineering',
            topics: [
              Topic(
                id: '101',
                name: 'Ohm\'s Law',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
              Topic(
                id: '102',
                name: 'Kirchhoff\'s Laws',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
            ],
          ),
        ],
        'Even': [],
      },
      '2nd': {'Odd': [], 'Even': []},
      '3rd': {'Odd': [], 'Even': []},
      '4th': {'Odd': [], 'Even': []},
    };

    data['CE'] = {
      '1st': {
        'Odd': [
          Course(
            id: 'ce_1st_odd_1',
            code: 'CE 1101',
            name: 'Engineering Mechanics',
            topics: [
              Topic(
                id: '201',
                name: 'Force Systems',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
              Topic(
                id: '202',
                name: 'Equilibrium',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
            ],
          ),
        ],
        'Even': [],
      },
      '2nd': {'Odd': [], 'Even': []},
      '3rd': {'Odd': [], 'Even': []},
      '4th': {'Odd': [], 'Even': []},
    };

    data['ME'] = {
      '1st': {
        'Odd': [
          Course(
            id: 'me_1st_odd_1',
            code: 'ME 1101',
            name: 'Basic Mechanical Engineering',
            topics: [
              Topic(
                id: '301',
                name: 'Thermodynamics',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
              Topic(
                id: '302',
                name: 'Fluid Mechanics',
                isSelected: false,
                ctType: CTType.none,
                createdAt: DateTime.now(),
              ),
            ],
          ),
        ],
        'Even': [],
      },
      '2nd': {'Odd': [], 'Even': []},
      '3rd': {'Odd': [], 'Even': []},
      '4th': {'Odd': [], 'Even': []},
    };
  }
}

class TopicStorage {
  static Future<void> saveTopics(
    String department,
    String year,
    String semester,
    List<Course> courses,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${department}_${year}_$semester';
      final List<Map<String, dynamic>> coursesJson = courses
          .map((c) => c.toJson())
          .toList();
      await prefs.setString(key, jsonEncode(coursesJson));
    } catch (e) {
      print('Error saving topics: $e');
    }
  }

  static Future<List<Course>?> loadTopics(
    String department,
    String year,
    String semester,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${department}_${year}_$semester';
      final String? data = prefs.getString(key);

      if (data != null) {
        final List<dynamic> coursesJson = jsonDecode(data);
        return coursesJson.map((c) => Course.fromJson(c)).toList();
      }
    } catch (e) {
      print('Error loading topics: $e');
    }
    return null;
  }
}

class TopicsPage extends StatefulWidget {
  final String department;
  final String year;
  final String semester;
  final bool isCR;

  const TopicsPage({
    super.key,
    required this.department,
    required this.year,
    required this.semester,
    this.isCR = false,
  });

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  Course? _selectedCourse;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newTopicController = TextEditingController();
  final TextEditingController _newCourseCodeController =
      TextEditingController();
  final TextEditingController _newCourseNameController =
      TextEditingController();
  bool _isLoading = true;
  late UserRole _userRole;
  final Set<String> _selectedTopicIds = {};

  @override
  void initState() {
    super.initState();
    _userRole = UserRole(role: widget.isCR ? UserRole.cr : UserRole.student);
    _initializeData();
    _searchController.addListener(_filterTopics);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newTopicController.dispose();
    _newCourseCodeController.dispose();
    _newCourseNameController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    CurriculumData.initialize();

    final savedCourses = await TopicStorage.loadTopics(
      widget.department,
      widget.year,
      widget.semester,
    );

    if (savedCourses != null && savedCourses.isNotEmpty) {
      _courses = savedCourses;
    } else {
      _courses =
          CurriculumData.data[widget.department]?[widget.year]?[widget
              .semester] ??
          [];

      if (_courses.isNotEmpty) {
        await TopicStorage.saveTopics(
          widget.department,
          widget.year,
          widget.semester,
          _courses,
        );
      }
    }

    if (_courses.isNotEmpty) {
      _selectedCourse = _courses.first;
    }

    _filterTopics();
    setState(() => _isLoading = false);
  }

  void _filterTopics() {
    if (_searchController.text.isEmpty) {
      _filteredCourses = List.from(_courses);
    } else {
      _filteredCourses = _courses
          .map((course) {
            final filteredTopics = course.topics
                .where(
                  (topic) => topic.name.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ),
                )
                .toList();

            return Course(
              id: course.id,
              code: course.code,
              name: course.name,
              topics: filteredTopics,
            );
          })
          .where((course) => course.topics.isNotEmpty)
          .toList();
    }
    setState(() {});
  }

  Future<void> _addCourse() async {
    final courseCode = _newCourseCodeController.text.trim();
    final courseName = _newCourseNameController.text.trim();

    if (courseCode.isEmpty || courseName.isEmpty) {
      _showSnackBar('Please enter both course code and name', isError: true);
      return;
    }

    final exists = _courses.any(
      (c) =>
          c.code.toLowerCase() == courseCode.toLowerCase() ||
          c.name.toLowerCase() == courseName.toLowerCase(),
    );

    if (exists) {
      _showSnackBar('Course already exists', isError: true);
      return;
    }

    final newCourse = Course(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: courseCode,
      name: courseName,
      topics: [],
    );

    setState(() {
      _courses.add(newCourse);
      _selectedCourse = newCourse;
      _filterTopics();
    });

    await TopicStorage.saveTopics(
      widget.department,
      widget.year,
      widget.semester,
      _courses,
    );

    _newCourseCodeController.clear();
    _newCourseNameController.clear();
    _showSnackBar('Course added successfully');
  }

  Future<void> _deleteCourse() async {
    if (_selectedCourse == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text(
          'Are you sure you want to delete "${_selectedCourse!.code} - ${_selectedCourse!.name}"?\n\nAll topics in this course will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _courses.removeWhere((c) => c.id == _selectedCourse!.id);
        if (_courses.isNotEmpty) {
          _selectedCourse = _courses.first;
        } else {
          _selectedCourse = null;
        }
        _selectedTopicIds.clear();
        _filterTopics();
      });

      await TopicStorage.saveTopics(
        widget.department,
        widget.year,
        widget.semester,
        _courses,
      );
      _showSnackBar('Course deleted successfully');
    }
  }

  void _showAddCourseDialog() {
    _newCourseCodeController.clear();
    _newCourseNameController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newCourseCodeController,
              decoration: const InputDecoration(
                labelText: 'Course Code',
                hintText: 'e.g., CSE 2101',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newCourseNameController,
              decoration: const InputDecoration(
                labelText: 'Course Name',
                hintText: 'e.g., Database Management',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addCourse();
            },
            child: const Text('Add Course'),
          ),
        ],
      ),
    );
  }

  void _addTopic() async {
    if (_selectedCourse == null) return;

    final topicName = _newTopicController.text.trim();

    if (topicName.isEmpty) {
      _showSnackBar('Topic name cannot be empty', isError: true);
      return;
    }

    if (topicName.length > 100) {
      _showSnackBar(
        'Topic name must be less than 100 characters',
        isError: true,
      );
      return;
    }

    final exists = _selectedCourse!.topics.any(
      (t) => t.name.toLowerCase() == topicName.toLowerCase(),
    );

    if (exists) {
      _showSnackBar('Topic already exists in this course', isError: true);
      return;
    }

    final newTopic = Topic(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: topicName,
      isSelected: false,
      ctType: CTType.none,
      createdAt: DateTime.now(),
    );

    setState(() {
      _selectedCourse!.topics.insert(0, newTopic);
      final courseIndex = _courses.indexWhere(
        (c) => c.id == _selectedCourse!.id,
      );
      if (courseIndex != -1) {
        _courses[courseIndex] = _selectedCourse!;
      }
      _filterTopics();
    });

    await TopicStorage.saveTopics(
      widget.department,
      widget.year,
      widget.semester,
      _courses,
    );

    _newTopicController.clear();
    _showSnackBar('Topic added successfully');
  }

  void _deleteSelectedTopics() async {
    if (_selectedTopicIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete ${_selectedTopicIds.length} selected topic(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        for (var course in _courses) {
          course.topics.removeWhere((t) => _selectedTopicIds.contains(t.id));
        }
        _selectedTopicIds.clear();
        if (_selectedCourse != null) {
          try {
            _selectedCourse = _courses.firstWhere(
              (c) => c.id == _selectedCourse!.id,
            );
          } catch (e) {
            _selectedCourse = _courses.isNotEmpty ? _courses.first : null;
          }
        }
        _filterTopics();
      });

      await TopicStorage.saveTopics(
        widget.department,
        widget.year,
        widget.semester,
        _courses,
      );
      _showSnackBar('Topics deleted successfully');
    }
  }

  void _applyCTToSelected(CTType ctType) {
    if (_selectedTopicIds.isEmpty) return;

    setState(() {
      for (var course in _courses) {
        for (var topic in course.topics) {
          if (_selectedTopicIds.contains(topic.id)) {
            topic.ctType = ctType;
          }
        }
      }
      _filterTopics();
    });

    TopicStorage.saveTopics(
      widget.department,
      widget.year,
      widget.semester,
      _courses,
    );
    _showSnackBar(
      '${ctType.displayName} applied to ${_selectedTopicIds.length} topic(s)',
    );
  }

  void _toggleTopicSelection(String topicId) {
    setState(() {
      if (_selectedTopicIds.contains(topicId)) {
        _selectedTopicIds.remove(topicId);
      } else {
        _selectedTopicIds.add(topicId);
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddTopicDialog() {
    _newTopicController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Topic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedCourse != null)
              Text(
                'Course: ${_selectedCourse!.code} - ${_selectedCourse!.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _newTopicController,
              decoration: const InputDecoration(
                labelText: 'Topic Name',
                hintText: 'Enter topic name',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _newTopicController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addTopic();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildCTButton(CTType ctType, Color color) {
    final isEnabled = _selectedTopicIds.isNotEmpty;

    return Expanded(
      child: ElevatedButton(
        onPressed: isEnabled ? () => _applyCTToSelected(ctType) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? color : Colors.grey.shade300,
          foregroundColor: isEnabled ? Colors.white : Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(ctType.displayName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.department} - ${widget.year} Year ${widget.semester}',
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Delete Course Button (CR only)
          if (_userRole.canDeleteCourse && _selectedCourse != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteCourse,
              tooltip: 'Delete Course',
            ),
          // Delete Selected Topics Button (CR only)
          if (_selectedTopicIds.isNotEmpty && _userRole.canDeleteTopic)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedTopics,
              tooltip: 'Delete selected',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No courses available for ${widget.department} ${widget.year} Year ${widget.semester}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  if (_userRole.canAddCourse)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: _showAddCourseDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Course'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : Column(
              children: [
                // Course Selection Row with Add Course Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<Course>(
                            value: _selectedCourse,
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: const Text('Select Course'),
                            items: _courses.map((course) {
                              return DropdownMenuItem(
                                value: course,
                                child: Text('${course.code} - ${course.name}'),
                              );
                            }).toList(),
                            onChanged: (course) {
                              setState(() {
                                _selectedCourse = course;
                                _selectedTopicIds.clear();
                              });
                            },
                          ),
                        ),
                      ),
                      if (_userRole.canAddCourse)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.blue,
                            ),
                            onPressed: _showAddCourseDialog,
                            tooltip: 'Add Course',
                            iconSize: 32,
                          ),
                        ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search topics...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // CT Action Buttons
                if (_selectedTopicIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Apply to selected:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildCTButton(CTType.ct1, Colors.red),
                            const SizedBox(width: 8),
                            _buildCTButton(CTType.ct2, Colors.green),
                            const SizedBox(width: 8),
                            _buildCTButton(CTType.ct3, Colors.orange),
                            const SizedBox(width: 8),
                            _buildCTButton(CTType.ct4, Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Topics List
                Expanded(
                  child: _selectedCourse == null
                      ? const Center(child: Text('No course selected'))
                      : RefreshIndicator(
                          onRefresh: _initializeData,
                          child:
                              _filteredCourses.isEmpty ||
                                  _filteredCourses
                                      .firstWhere(
                                        (c) => c.id == _selectedCourse!.id,
                                        orElse: () => Course(
                                          id: '',
                                          code: '',
                                          name: '',
                                          topics: [],
                                        ),
                                      )
                                      .topics
                                      .isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.topic,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchController.text.isEmpty
                                            ? 'No topics in this course'
                                            : 'No matching topics found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      if (_userRole.canAddTopic &&
                                          _searchController.text.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: ElevatedButton.icon(
                                            onPressed: _showAddTopicDialog,
                                            icon: const Icon(Icons.add),
                                            label: const Text(
                                              'Add First Topic',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _selectedCourse!.topics.length,
                                  itemBuilder: (context, index) {
                                    final topic =
                                        _selectedCourse!.topics[index];
                                    final isSelected = _selectedTopicIds
                                        .contains(topic.id);

                                    if (_searchController.text.isNotEmpty &&
                                        !topic.name.toLowerCase().contains(
                                          _searchController.text.toLowerCase(),
                                        )) {
                                      return const SizedBox.shrink();
                                    }

                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Card(
                                        color: topic.ctType.color,
                                        elevation: isSelected ? 4 : 1,
                                        child: ListTile(
                                          leading: Checkbox(
                                            value: isSelected,
                                            onChanged: (value) {
                                              _toggleTopicSelection(topic.id);
                                            },
                                            activeColor: Colors.blue,
                                          ),
                                          title: Text(
                                            topic.name,
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          subtitle: topic.ctType != CTType.none
                                              ? Text(
                                                  'Selected as: ${topic.ctType.displayName}',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                )
                                              : null,
                                          trailing: _userRole.canDeleteTopic
                                              ? IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                  ),
                                                  onPressed: () {
                                                    _selectedTopicIds.clear();
                                                    _selectedTopicIds.add(
                                                      topic.id,
                                                    );
                                                    _deleteSelectedTopics();
                                                  },
                                                  color: Colors.red.shade700,
                                                )
                                              : null,
                                          onTap: () {
                                            _toggleTopicSelection(topic.id);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                ),
              ],
            ),
      floatingActionButton: _userRole.canAddTopic && _selectedCourse != null
          ? FloatingActionButton.extended(
              onPressed: _showAddTopicDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Topic'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}
