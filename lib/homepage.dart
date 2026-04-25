import 'package:app7/about.dart';
import 'package:app7/notice.dart';
import 'package:app7/voting.dart';
import 'package:app7/content.dart';
import 'daily_learn.dart';
import 'package:app7/cr_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'diganto/community_screen.dart';

class Homepage extends StatefulWidget {
  final bool isCR;
  const Homepage({super.key, required this.isCR});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(color: Colors.teal.shade300),
          child: ListView(
            children: [
              const DrawerHeader(
                child: Center(
                  child: Text(
                    "EduBuddy",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (widget.isCR) ...[
                ListTile(
                  leading: const Icon(
                    Icons.dashboard_customize,
                    color: Colors.amber,
                  ),
                  title: const Text(
                    "CR Dashboard",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CRDashboard(
                          currentCREmail:
                              FirebaseAuth.instance.currentUser?.email,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
              ],
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Home", style: TextStyle(fontSize: 18)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text("Notice", style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Notice(isCR: widget.isCR),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.poll),
                title: const Text("Voting", style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Voting(isCR: widget.isCR),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_paste),
                title: const Text("Interactive Syllabus", style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Content(isCR: widget.isCR),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.question_answer),
                title: const Text("Doubt Solving", style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommunityScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text(
                  "Daily Learn",
                  style: TextStyle(fontSize: 18),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DailyLearn()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text("About", style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => About()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Sign Out",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await signOut();
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("EduBuddy Home"),
        backgroundColor: Colors.blue.shade300,
        foregroundColor: Colors.white,
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade200.withOpacity(0.6),
              Colors.blue.shade100.withOpacity(0.5),
              Colors.white.withOpacity(0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blue.shade300,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_circle,
                          size: 60,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome,',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'No email',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        if (widget.isCR)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Class Representative',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blue.shade300,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 40,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Contents, CT syllabus, notices, polls, and opinions — everything just one tap away.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'For more information, visit "About" section.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  //Quick acction button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickActionButton(
                        context,
                        icon: Icons.notifications_active,
                        label: 'Notices',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Notice(isCR: widget.isCR),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.poll,
                        label: 'Voting',
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Voting(isCR: widget.isCR),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.content_paste,
                        label: 'Content',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Content(isCR: widget.isCR),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
