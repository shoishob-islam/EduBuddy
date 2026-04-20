import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─────────────────────────────────────────────
// Firestore structure:
//
//  daily_lessons/{lessonId}
//    title, description, link, category,
//    youtubeLink (optional), gdriveLink (optional)
//
//  user_progress/{uid}
//    streakCount        : int
//    lastActiveDate     : String  (yyyy-MM-dd)
//    completedLessons   : List<String>  (lessonIds)
// ─────────────────────────────────────────────

class DailyLearn extends StatefulWidget {
  const DailyLearn({super.key});

  @override
  State<DailyLearn> createState() => _DailyLearnState();
}

class _DailyLearnState extends State<DailyLearn> {
  // ── state ────────────────────────────────────
  bool _isLoading = true;
  int streakCount = 0;
  Set<String> completedIds = {};
  List<Map<String, dynamic>> dailyLessons = [];

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  // today's date as a comparable string
  String get _todayStr {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ── fallback hardcoded lessons (used if Firestore has no data) ───
  static const List<Map<String, dynamic>> _fallbackLessons = [
    // Programming
    {
      'id': 'python_fundamentals',
      'title': 'Python Fundamentals',
      'description': 'Learn Python basics for problem solving.',
      'category': 'Python',
      'link': 'https://docs.python.org/3/tutorial/',
    },
    {
      'id': 'flutter_basics',
      'title': 'Flutter Basics',
      'description': 'Learn the basics of Flutter and widgets.',
      'category': 'Flutter',
      'link': 'https://docs.flutter.dev/get-started',
    },
    {
      'id': 'dart_language',
      'title': 'Dart Language',
      'description': 'Understand Dart syntax and structures.',
      'category': 'Flutter',
      'link': 'https://dart.dev/guides',
    },
    {
      'id': 'js_basics',
      'title': 'JavaScript Basics',
      'description': 'Understand JavaScript for web development.',
      'category': 'JavaScript',
      'link':
          'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide',
    },
    // Discrete Math
    {
      'id': 'logic_proof',
      'title': 'Logic and Proof',
      'description': 'Propositional logic, predicates, proofs.',
      'category': 'Discrete Math',
      'link':
          'https://www.geeksforgeeks.org/discrete-mathematics-logic/',
    },
    {
      'id': 'sets_cardinality',
      'title': 'Sets & Cardinality',
      'description': 'Set operations, relations, cardinality.',
      'category': 'Discrete Math',
      'link':
          'https://www.geeksforgeeks.org/sets-in-discrete-mathematics/',
    },
    {
      'id': 'functions_relations',
      'title': 'Functions & Relations',
      'description': 'Functions and relations.',
      'category': 'Discrete Math',
      'link':
          'https://www.geeksforgeeks.org/functions-discrete-mathematics/',
    },
    {
      'id': 'counting',
      'title': 'Counting Techniques',
      'description': 'Permutations, combinations, pigeonhole principle.',
      'category': 'Discrete Math',
      'link': 'https://www.geeksforgeeks.org/counting-principles/',
    },
    {
      'id': 'graphs',
      'title': 'Graphs',
      'description': 'Graph theory basics.',
      'category': 'Discrete Math',
      'link':
          'https://www.geeksforgeeks.org/graph-data-structure-and-algorithms/',
    },
    // DLD
    {
      'id': 'number_systems',
      'title': 'Number Systems & Codes',
      'description': 'Binary, octal, hexadecimal number systems.',
      'category': 'DLD',
      'link': 'https://www.geeksforgeeks.org/number-system-and-codes/',
    },
    {
      'id': 'boolean_algebra',
      'title': 'Boolean Algebra',
      'description': 'Boolean laws and simplification.',
      'category': 'DLD',
      'link': 'https://www.geeksforgeeks.org/boolean-algebra/',
    },
    {
      'id': 'combinational_logic',
      'title': 'Combinational Logic Circuits',
      'description': 'Adders, subtractors, multiplexers.',
      'category': 'DLD',
      'link':
          'https://www.geeksforgeeks.org/combinational-logic-circuits/',
    },
    {
      'id': 'sequential_logic',
      'title': 'Sequential Logic & Flip-Flops',
      'description': 'Flip-flops, counters, registers.',
      'category': 'DLD',
      'link': 'https://www.geeksforgeeks.org/sequential-circuits/',
    },
    // Electrical
    {
      'id': 'dc_machines',
      'title': 'DC Machines',
      'description': 'DC motors and generators.',
      'category': 'Electrical',
      'link': 'https://www.geeksforgeeks.org/dc-machines/',
    },
    {
      'id': 'ac_machines',
      'title': 'AC Machines',
      'description': 'Transformers and induction motors.',
      'category': 'Electrical',
      'link': 'https://www.geeksforgeeks.org/ac-machines/',
    },
    {
      'id': 'measuring_instruments',
      'title': 'Measuring Instruments',
      'description': 'Analog and digital measuring instruments.',
      'category': 'Electrical',
      'link':
          'https://www.geeksforgeeks.org/electrical-measuring-instruments/',
    },
    // Math
    {
      'id': 'vector_calculus',
      'title': 'Vector Calculus',
      'description': 'Gradient, divergence, curl.',
      'category': 'Math',
      'link': 'https://www.geeksforgeeks.org/vector-calculus/',
    },
    {
      'id': 'matrices',
      'title': 'Matrices & Linear Equations',
      'description': 'Matrices and linear systems.',
      'category': 'Math',
      'link': 'https://www.geeksforgeeks.org/matrices/',
    },
    {
      'id': 'eigenvalues',
      'title': 'Eigenvalues & Eigenvectors',
      'description': 'Eigenvalues and eigenvectors.',
      'category': 'Math',
      'link':
          'https://www.geeksforgeeks.org/eigenvalues-and-eigenvectors/',
    },
    // Economics
    {
      'id': 'intro_economics',
      'title': 'Introduction to Economics',
      'description': 'Basic concepts of economics.',
      'category': 'Economics',
      'link': 'https://www.investopedia.com/terms/e/economics.asp',
    },
    {
      'id': 'demand_supply',
      'title': 'Demand, Supply & Elasticity',
      'description': 'Market demand, supply, and elasticity.',
      'category': 'Economics',
      'link': 'https://www.investopedia.com/terms/l/lawofdemand.asp',
    },
    {
      'id': 'bd_economy',
      'title': 'Economy of Bangladesh',
      'description': 'Economic structure of Bangladesh.',
      'category': 'Economics',
      'link': 'https://en.wikipedia.org/wiki/Economy_of_Bangladesh',
    },
    // Civics
    {
      'id': 'state_govt',
      'title': 'State and Government',
      'description': 'Concept of state and governance.',
      'category': 'Civics',
      'link':
          'https://www.britannica.com/topic/state-sovereign-political-entity',
    },
    {
      'id': 'forms_govt',
      'title': 'Forms of Government',
      'description': 'Democracy, monarchy, dictatorship.',
      'category': 'Civics',
      'link': 'https://www.britannica.com/topic/government',
    },
    // Sociology
    {
      'id': 'intro_sociology',
      'title': 'Introduction to Sociology',
      'description': 'Society, culture, and social system.',
      'category': 'Sociology',
      'link': 'https://www.britannica.com/topic/sociology',
    },
    {
      'id': 'bd_social_problems',
      'title': 'Social Problems of Bangladesh',
      'description': 'Social development issues.',
      'category': 'Sociology',
      'link':
          'https://en.wikipedia.org/wiki/Social_issues_in_Bangladesh',
    },
  ];

  // ── lifecycle ────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([_loadLessons(), _loadUserProgress()]);
    if (mounted) setState(() => _isLoading = false);
  }

  // ── load lessons from Firestore (fallback to hardcoded) ──────────
  Future<void> _loadLessons() async {
    try {
      final snap = await _db.collection('daily_lessons').get();
      if (snap.docs.isNotEmpty) {
        dailyLessons = snap.docs.map((d) {
          final data = d.data();
          data['id'] = d.id;
          return data;
        }).toList();
      } else {
        // Firestore-এ কিছু নেই → fallback use করো
        // এবং একবার Firestore-এ seed করে দাও
        dailyLessons = List<Map<String, dynamic>>.from(_fallbackLessons);
        _seedLessonsToFirestore();
      }
    } catch (_) {
      dailyLessons = List<Map<String, dynamic>>.from(_fallbackLessons);
    }
  }

  // fallback lessons Firestore-এ একবার লিখে দেওয়া
  Future<void> _seedLessonsToFirestore() async {
    final batch = _db.batch();
    for (final lesson in _fallbackLessons) {
      final id = lesson['id'] as String;
      final ref = _db.collection('daily_lessons').doc(id);
      final data = Map<String, dynamic>.from(lesson)..remove('id');
      batch.set(ref, data, SetOptions(merge: true));
    }
    await batch.commit();
  }

  // ── load user progress from Firestore ───────────────────────────
  Future<void> _loadUserProgress() async {
    if (_uid.isEmpty) return;
    try {
      final doc = await _db.collection('user_progress').doc(_uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final savedDate = data['lastActiveDate'] as String? ?? '';
        final savedStreak = data['streakCount'] as int? ?? 0;
        final List<dynamic> saved =
            data['completedLessons'] as List<dynamic>? ?? [];

        final today = _todayStr;
        final yesterday = _getYesterdayStr();

        // Daily reset: নতুন দিনে completedLessons reset
        if (savedDate != today) {
          completedIds = {};
          // streak logic
          if (savedDate == yesterday) {
            // গতকাল active ছিল → streak বজায়
            streakCount = savedStreak;
          } else if (savedDate.isEmpty) {
            streakCount = savedStreak;
          } else {
            // মাঝে gap → streak reset
            streakCount = 0;
          }
        } else {
          completedIds = Set<String>.from(saved.map((e) => e.toString()));
          streakCount = savedStreak;
        }
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
  }

  String _getYesterdayStr() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
  }

  // ── mark a lesson complete ───────────────────────────────────────
  Future<void> _markComplete(String lessonId) async {
    if (completedIds.contains(lessonId)) return; // already done

    setState(() => completedIds.add(lessonId));
    if (_uid.isEmpty) return;

    try {
      await _db.collection('user_progress').doc(_uid).set({
        'completedLessons': FieldValue.arrayUnion([lessonId]),
        'lastActiveDate': _todayStr,
        'streakCount': streakCount,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving completed: $e');
    }
  }

  // ── keep streak (FAB) ────────────────────────────────────────────
  Future<void> _keepStreak() async {
    setState(() => streakCount += 1);
    if (_uid.isEmpty) return;
    try {
      await _db.collection('user_progress').doc(_uid).set({
        'streakCount': streakCount,
        'lastActiveDate': _todayStr,
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔥 Streak updated! $streakCount days'),
            backgroundColor: Colors.deepOrange,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating streak: $e');
    }
  }

  // ── category color ───────────────────────────────────────────────
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'python':
      case 'flutter':
      case 'javascript':
        return Colors.deepPurple;
      case 'discrete math':
      case 'math':
        return Colors.indigo;
      case 'dld':
      case 'electrical':
        return Colors.teal;
      case 'economics':
      case 'civics':
      case 'sociology':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  // ── build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final double progress =
        dailyLessons.isEmpty ? 0 : completedIds.length / dailyLessons.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Daily Learn'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Progress',
            onPressed: () async {
              setState(() => _isLoading = true);
              await _loadUserProgress();
              if (mounted) setState(() => _isLoading = false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── header card ──────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5D8BF4), Color(0xFF7CBAFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Daily Learning Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Keep the streak alive and explore today's curated lessons.",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _MetricCard(
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '$streakCount days',
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 12),
                    _MetricCard(
                      icon: Icons.check_circle,
                      label: 'Completed',
                      value: '${completedIds.length}/${dailyLessons.length}',
                      color: Colors.greenAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: progress.clamp(0, 1),
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}% complete',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // ── lesson list ──────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dailyLessons.length,
              itemBuilder: (context, index) {
                final lesson = dailyLessons[index];
                final lessonId = lesson['id'] as String? ?? index.toString();
                final category = lesson['category'] as String? ?? 'General';
                final isDone = completedIds.contains(lessonId);
                final cardColor =
                    _getCategoryColor(category).withOpacity(0.08);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    border: isDone
                        ? Border.all(color: Colors.green.shade300, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        // mark complete in Firestore
                        await _markComplete(lessonId);
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonDetailPage(
                              title: lesson['title'] as String? ?? '',
                              description:
                                  lesson['description'] as String? ?? '',
                              link: lesson['link'] as String? ?? '',
                              youtubeLink:
                                  lesson['youtubeLink'] as String?,
                              gdriveLink:
                                  lesson['gdriveLink'] as String?,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // category icon box
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? Colors.green.withOpacity(0.12)
                                    : cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: isDone
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green, size: 28)
                                    : Text(
                                        category[0].toUpperCase(),
                                        style: TextStyle(
                                          color:
                                              _getCategoryColor(category),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          lesson['title'] as String? ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: isDone
                                                ? Colors.grey
                                                : Colors.black87,
                                            decoration: isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                      if (isDone)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'Done ✓',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    lesson['description'] as String? ?? '',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Chip(
                                        backgroundColor:
                                            _getCategoryColor(category)
                                                .withOpacity(0.15),
                                        label: Text(
                                          category,
                                          style: TextStyle(
                                            color:
                                                _getCategoryColor(category),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _keepStreak,
        icon: const Icon(Icons.whatshot),
        label: const Text('Keep Streak'),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color,
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lesson Detail Page
// ─────────────────────────────────────────────────────────────────────────────
class LessonDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String link;
  final String? youtubeLink;
  final String? gdriveLink;

  const LessonDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.link,
    this.youtubeLink,
    this.gdriveLink,
  });

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'Resources',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ResourceButton(
              icon: Icons.link,
              label: 'Open Docs',
              color: Colors.blue,
              onPressed: () => _openLink(widget.link),
            ),
            if (widget.youtubeLink != null) ...[
              const SizedBox(height: 12),
              _ResourceButton(
                icon: Icons.ondemand_video,
                label: 'Watch on YouTube',
                color: Colors.redAccent,
                onPressed: () => _openLink(widget.youtubeLink!),
              ),
            ],
            if (widget.gdriveLink != null) ...[
              const SizedBox(height: 12),
              _ResourceButton(
                icon: Icons.cloud,
                label: 'Open on Google Drive',
                color: Colors.green,
                onPressed: () => _openLink(widget.gdriveLink!),
              ),
            ],
            const SizedBox(height: 26),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                '💡 Advice: Practice what you learn today before sleeping to retain more knowledge.',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _ResourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ResourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size.fromHeight(50),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
