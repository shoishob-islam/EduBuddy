import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'doubt_model.dart';
import 'doubt_service.dart';
import 'app_theme.dart';
import 'doubt_card.dart';
import 'ask_doubt_screen.dart'hide AppTheme, DoubtSubject;

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DoubtSubject? _activeSubject;

  final List<Map<String, dynamic>> _subjects = [
    {'label': 'All', 'icon': Icons.all_inclusive, 'color': AppTheme.neonPurple, 'subject': null},
    {'label': 'CSE', 'icon': Icons.computer, 'color': Color(0xFF9B30FF), 'subject': DoubtSubject.cse},
    {'label': 'Physics', 'icon': Icons.science, 'color': Color(0xFF30AAFF), 'subject': DoubtSubject.physics},
    {'label': 'Chemistry', 'icon': Icons.biotech, 'color': Color(0xFF30FFB0), 'subject': DoubtSubject.chemistry},
    {'label': 'EEE', 'icon': Icons.flash_on, 'color': Color(0xFFFFB030), 'subject': DoubtSubject.eee},
    {'label': 'English', 'icon': Icons.menu_book, 'color': Color(0xFFFF6030), 'subject': DoubtSubject.english},
    {'label': 'Maths', 'icon': Icons.calculate, 'color': Color(0xFFFF30AA), 'subject': DoubtSubject.mathematics},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doubtService = DoubtService();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildSubjectGrid()),
              SliverToBoxAdapter(child: _buildTabBar()),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDoubtsFeed(doubtService, currentUser?.uid ?? '', 'trending'),
              _buildDoubtsFeed(doubtService, currentUser?.uid ?? '', 'recent'),
              _buildDoubtsFeed(doubtService, currentUser?.uid ?? '', 'unsolved'),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Learn from each other',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.neonShadow,
                ),
                child: Text(
                  '🔥 Live',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Search doubts, topics...',
                  style: GoogleFonts.inter(
                    color: AppTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSubjectGrid() {
    return SizedBox(
      height: 92,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _subjects.length,
        itemBuilder: (context, index) {
          final subject = _subjects[index];
          final isActive = _activeSubject == subject['subject'];
          return GestureDetector(
            onTap: () => setState(() {
              _activeSubject =
                  isActive ? null : subject['subject'] as DoubtSubject?;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              width: 72,
              decoration: BoxDecoration(
                color: isActive
                    ? (subject['color'] as Color).withOpacity(0.2)
                    : AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? (subject['color'] as Color)
                      : AppTheme.borderColor,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    subject['icon'] as IconData,
                    size: 24,
                    color: isActive
                        ? (subject['color'] as Color)
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subject['label'] as String,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? (subject['color'] as Color)
                          : AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textMuted,
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: '🔥 Trending'),
          Tab(text: '🆕 Recent'),
          Tab(text: '❓ Unsolved'),
        ],
      ),
    );
  }

  Widget _buildDoubtsFeed(
      DoubtService doubtService, String currentUserId, String type) {
    return StreamBuilder<List<DoubtModel>>(
      stream: doubtService.getDoubts(subject: _activeSubject),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.neonPurple),
          );
        }

        List<DoubtModel> doubts = snapshot.data ?? [];

        if (type == 'unsolved') {
          doubts = doubts.where((d) => !d.isResolved).toList();
        } else if (type == 'trending') {
          doubts.sort((a, b) => b.upvotes.compareTo(a.upvotes));
        }

        if (doubts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.question_answer_outlined,
                    size: 52, color: AppTheme.textMuted),
                const SizedBox(height: 16),
                Text(
                  'No doubts found',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 90),
          itemCount: doubts.length,
          itemBuilder: (context, index) {
            return DoubtCard(
              doubt: doubts[index],
              currentUserId: currentUserId,
              onUpvote: () =>
                  doubtService.upvoteDoubt(doubts[index].id, currentUserId),
            );
          },
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AskDoubtScreen()),
      ),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: AppTheme.neonShadow,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
    }
/// No changes are needed in the `$SELECTION_PLACEHOLDER$` section as it is currently empty.
/// If you have specific functionality or code to add, please provide more details.
