import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';

class DailyLearn extends StatefulWidget {
  const DailyLearn({super.key});

  @override
  State<DailyLearn> createState() => _DailyLearnState();
}

class _DailyLearnState extends State<DailyLearn> {
  int streakCount = 3;
  int completedLessons = 0;

  final List<Map<String, String>> dailyLessons = const [
    // ================= Programming =================
    {
      'title': 'Python Fundamentals',
      'description': 'Learn Python basics for problem solving.',
      'language': 'Python',
      'link': 'https://docs.python.org/3/tutorial/',
    },
    {
      'title': 'Flutter Basics',
      'description': 'Learn the basics of Flutter and widgets.',
      'language': 'Flutter',
      'link': 'https://docs.flutter.dev/get-started',
    },
    {
      'title': 'Dart Language',
      'description': 'Understand Dart syntax and structures.',
      'language': 'Flutter',
      'link': 'https://dart.dev/guides',
    },
    {
      'title': 'JavaScript Basics',
      'description': 'Understand JavaScript for web development.',
      'language': 'JavaScript',
      'link': 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide',
    },

    // ================= Discrete Mathematics =================
    {
      'title': 'Logic and Proof',
      'description': 'Propositional logic, predicates, proofs.',
      'language': 'Discrete Math',
      'link': 'https://www.geeksforgeeks.org/discrete-mathematics-logic/',
    },
    {
      'title': 'Sets & Cardinality',
      'description': 'Set operations, relations, cardinality.',
      'language': 'Discrete Math',
      'link': 'https://www.geeksforgeeks.org/sets-in-discrete-mathematics/',
    },
    {
      'title': 'Functions & Relations',
      'description': 'Functions and relations.',
      'language': 'Discrete Math',
      'link': 'https://www.geeksforgeeks.org/functions-discrete-mathematics/',
    },
    {
      'title': 'Counting Techniques',
      'description': 'Permutations, combinations, pigeonhole principle.',
      'language': 'Discrete Math',
      'link': 'https://www.geeksforgeeks.org/counting-principles/',
    },
    {
      'title': 'Graphs',
      'description': 'Graph theory basics.',
      'language': 'Discrete Math',
      'link':
          'https://www.geeksforgeeks.org/graph-data-structure-and-algorithms/',
    },

    // ================= Digital Logic Design =================
    {
      'title': 'Number Systems & Codes',
      'description': 'Binary, octal, hexadecimal number systems.',
      'language': 'DLD',
      'link': 'https://www.geeksforgeeks.org/number-system-and-codes/',
    },
    {
      'title': 'Boolean Algebra',
      'description': 'Boolean laws and simplification.',
      'language': 'DLD',
      'link': 'https://www.geeksforgeeks.org/boolean-algebra/',
    },
    {
      'title': 'Combinational Logic Circuits',
      'description': 'Adders, subtractors, multiplexers.',
      'language': 'DLD',
      'link': 'https://www.geeksforgeeks.org/combinational-logic-circuits/',
    },
    {
      'title': 'Sequential Logic & Flip-Flops',
      'description': 'Flip-flops, counters, registers.',
      'language': 'DLD',
      'link': 'https://www.geeksforgeeks.org/sequential-circuits/',
    },

    // ================= Electrical Drives & Instrumentation =================
    {
      'title': 'DC Machines',
      'description': 'DC motors and generators.',
      'language': 'Electrical',
      'link': 'https://www.geeksforgeeks.org/dc-machines/',
    },
    {
      'title': 'AC Machines',
      'description': 'Transformers and induction motors.',
      'language': 'Electrical',
      'link': 'https://www.geeksforgeeks.org/ac-machines/',
    },
    {
      'title': 'Measuring Instruments',
      'description': 'Analog and digital measuring instruments.',
      'language': 'Electrical',
      'link': 'https://www.geeksforgeeks.org/electrical-measuring-instruments/',
    },

    // ================= Vector Analysis & Linear Algebra =================
    {
      'title': 'Vector Calculus',
      'description': 'Gradient, divergence, curl.',
      'language': 'Math',
      'link': 'https://www.geeksforgeeks.org/vector-calculus/',
    },
    {
      'title': 'Matrices & Linear Equations',
      'description': 'Matrices and linear systems.',
      'language': 'Math',
      'link': 'https://www.geeksforgeeks.org/matrices/',
    },
    {
      'title': 'Eigenvalues & Eigenvectors',
      'description': 'Eigenvalues and eigenvectors.',
      'language': 'Math',
      'link': 'https://www.geeksforgeeks.org/eigenvalues-and-eigenvectors/',
    },

    // ================= Economics =================
    {
      'title': 'Introduction to Economics',
      'description': 'Basic concepts of economics.',
      'language': 'Economics',
      'link': 'https://www.investopedia.com/terms/e/economics.asp',
    },
    {
      'title': 'Demand, Supply & Elasticity',
      'description': 'Market demand, supply, and elasticity.',
      'language': 'Economics',
      'link': 'https://www.investopedia.com/terms/l/lawofdemand.asp',
    },
    {
      'title': 'Economy of Bangladesh',
      'description': 'Economic structure of Bangladesh.',
      'language': 'Economics',
      'link': 'https://en.wikipedia.org/wiki/Economy_of_Bangladesh',
    },

    // ================= Government & Sociology =================
    {
      'title': 'State and Government',
      'description': 'Concept of state and governance.',
      'language': 'Civics',
      'link':
          'https://www.britannica.com/topic/state-sovereign-political-entity',
    },
    {
      'title': 'Forms of Government',
      'description': 'Democracy, monarchy, dictatorship.',
      'language': 'Civics',
      'link': 'https://www.britannica.com/topic/government',
    },
    {
      'title': 'Introduction to Sociology',
      'description': 'Society, culture, and social system.',
      'language': 'Sociology',
      'link': 'https://www.britannica.com/topic/sociology',
    },
    {
      'title': 'Social Problems of Bangladesh',
      'description': 'Social development issues.',
      'language': 'Sociology',
      'link': 'https://en.wikipedia.org/wiki/Social_issues_in_Bangladesh',
    },
  ];

  String dailyAdvice =
      "📌 Consistency beats intensity. Learn a little every day!";

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

  @override
  Widget build(BuildContext context) {
    final double progress = dailyLessons.isEmpty
        ? 0
        : completedLessons / dailyLessons.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Daily Learn'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
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
                  'Keep the streak alive and explore today’s curated lessons.',
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
                      value: '$completedLessons/${dailyLessons.length}',
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dailyLessons.length,
              itemBuilder: (context, index) {
                final lesson = dailyLessons[index];
                final category = lesson['language'] ?? 'General';
                final cardColor = _getCategoryColor(category).withOpacity(0.08);

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
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
                      onTap: () {
                        setState(() {
                          completedLessons = (completedLessons + 1).clamp(
                            0,
                            dailyLessons.length,
                          );
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonDetailPage(
                              title: lesson['title']!,
                              description: lesson['description']!,
                              link: lesson['link']!,
                              youtubeLink: lesson['youtube'],
                              gdriveLink: lesson['gdrive'],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  category[0].toUpperCase(),
                                  style: TextStyle(
                                    color: _getCategoryColor(category),
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
                                  Text(
                                    lesson['title']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    lesson['description']!,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Chip(
                                        backgroundColor: _getCategoryColor(
                                          category,
                                        ).withOpacity(0.15),
                                        label: Text(
                                          category,
                                          style: TextStyle(
                                            color: _getCategoryColor(category),
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
        onPressed: () {
          setState(() {
            streakCount += 1;
          });
        },
        icon: const Icon(Icons.whatshot),
        label: const Text('Keep Streak'),
      ),
    );
  }
}

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
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
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

// ================= Lesson Detail Page =================
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open link: $url')));
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
