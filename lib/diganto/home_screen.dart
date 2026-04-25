import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'doubt_model.dart'; // Ensure this file exists and contains the DoubtModel class
import 'auth_service.dart'; // Ensure this file exists and contains the AuthService class
import 'doubt_service.dart'; // Ensure this file exists and contains the DoubtService class
import 'app_theme.dart'; // Ensure this file exists and contains the AppTheme class
import 'animated_subject_text.dart'; // Ensure this file exists and contains the AnimatedSubjectText widget
import 'doubt_card.dart'; // Ensure this file exists and contains the DoubtCard widget
import 'ask_doubt_screen.dart' hide AppTheme, DoubtSubject, DoubtInputType; // Ensure this file exists and contains the AskDoubtScreen widget
import 'notification_screen.dart'; // Ensure this file exists and contains the NotificationScreen widget
import 'notification_service.dart'; // Ensure this file exists and contains the NotificationService class

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  DoubtSubject? _selectedFilter;
  late AnimationController _headerController;
  late Animation<double> _headerFade;

  final List<DoubtSubject> _filters = [
    ...DoubtSubject.values,
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _headerFade =
        CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final doubtService = context.read<DoubtService>();
    final notificationService = context.read<NotificationService>();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _headerFade,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: _buildTopBar(context, currentUser, notificationService),
              ),
              // Hero Section
              SliverToBoxAdapter(
                child: _buildHeroSection(),
              ),
              // Ask Question Bar
              SliverToBoxAdapter(
                child: _buildAskQuestionBar(context, currentUser),
              ),
              // Filter Chips
              SliverToBoxAdapter(
                child: _buildFilterChips(),
              ),
              // Recent Doubts Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Doubts',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'See all',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.neonPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Doubts Feed
              _buildDoubtsFeed(doubtService, currentUser?.uid ?? ''),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    User? user,
    NotificationService notifService,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Logo
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school_rounded,
                size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            'StudyHive',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          // Notification Bell
          StreamBuilder<int>(
            stream: user != null
                ? notifService.getUnreadCount(user.uid)
                : Stream.value(0),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationScreen()),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AppTheme.textPrimary,
                        size: 22,
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppTheme.neonPurple,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonPurple.withOpacity(0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              count > 9 ? '9+' : count.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          // Avatar
          CircleAvatar(
            radius: 21,
            backgroundColor: AppTheme.neonPurple.withOpacity(0.2),
            child: Text(
              (user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w700,
                color: AppTheme.neonPurple,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0A35), Color(0xFF0D0D1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonPurple.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonPurple.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.neonPurple.withOpacity(0.3)),
                ),
                child: Text(
                  '🎓 For Students',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.neonPurpleLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Need help with',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          // Animated subject text
          const AnimatedSubjectText(),
          const SizedBox(height: 12),
          Text(
            'Post your doubts, get answers from peers, and build knowledge together.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAskQuestionBar(BuildContext context, User? user) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search/Ask Bar
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AskDoubtScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppTheme.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ask your doubt here...',
                      style: GoogleFonts.inter(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    color: AppTheme.borderColor,
                  ),
                  const SizedBox(width: 12),
                  _buildInputModeIcon(Icons.keyboard, 'Type'),
                  const SizedBox(width: 10),
                  _buildInputModeIcon(Icons.camera_alt_outlined, 'Photo'),
                  const SizedBox(width: 10),
                  _buildInputModeIcon(Icons.mic_outlined, 'Voice'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Quick action buttons
          Row(
            children: [
              _buildQuickActionBtn(
                context,
                icon: Icons.keyboard,
                label: 'Type',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AskDoubtScreen(defaultInputType: 'text'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildQuickActionBtn(
                context,
                icon: Icons.photo_camera,
                label: 'Photo',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AskDoubtScreen(defaultInputType: 'image'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildQuickActionBtn(
                context,
                icon: Icons.mic,
                label: 'Voice',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AskDoubtScreen(defaultInputType: 'voice'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputModeIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.neonPurpleLight),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppTheme.neonPurpleLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.neonPurple.withOpacity(0.15),
                AppTheme.neonPurple.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.neonPurple.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppTheme.neonPurpleLight),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neonPurpleLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: _filters.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedFilter == null;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = null),
              child: _buildChip('All', isSelected),
            );
          }
          final subject = _filters[index - 1];
          final isSelected = _selectedFilter == subject;
          return GestureDetector(
            onTap: () => setState(
                () => _selectedFilter = isSelected ? null : subject),
            child: _buildChip(subject.subjectLabel, isSelected,
                color: subject.subjectColor),
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
           ? (color ?? AppTheme.neonPurple).withValues(alpha: 0.2)
            : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? (color ?? AppTheme.neonPurple)
              : AppTheme.borderColor,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected
              ? (color ?? AppTheme.neonPurple)
              : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDoubtsFeed(DoubtService doubtService, String currentUserId) {
    return StreamBuilder<List<DoubtModel>>(
      stream: doubtService.getDoubts(subject: _selectedFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppTheme.neonPurple),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text(
                'Error loading doubts',
                style: GoogleFonts.inter(color: AppTheme.textSecondary),
              ),
            ),
          );
        }

        final doubts = snapshot.data ?? [];

        if (doubts.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: Column(
                  children: [
                    Icon(
                      Icons.question_answer_outlined,
                      size: 60,
                      color: AppTheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No doubts posted yet.',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Be the first to post a doubt!',
                      style: GoogleFonts.inter(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return DoubtCard(
                doubt: doubts[index],
                currentUserId: currentUserId,
                onUpvote: () {
                  doubtService.upvoteDoubt(
                    doubts[index].id,
                    currentUserId,
                  );
                },
              );
            },
            childCount: doubts.length,
          ),
        );
      },
    );
  }
}
