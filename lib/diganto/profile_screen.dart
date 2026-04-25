import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'user_model.dart';
import 'doubt_model.dart';
import 'auth_service.dart';
import 'doubt_service.dart';
import 'app_theme.dart';
import 'doubt_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditMode = false;
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController();
  String? _selectedBranch;
  String? _selectedYear;

  final List<String> _branches = [
    'CSE', 'EEE', 'ECE', 'Mechanical', 'Civil', 'Other'
  ];
  final List<String> _years = [
    '1st Year', '2nd Year', '3rd Year', '4th Year', 'PG'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  // Future<void> _logout(BuildContext context) async {
  //   final authService = context.read<AuthService>();
  //   await authService.signOut();
  //   if (context.mounted) {
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(builder: (_) => const LoginScreen()),
  //       (route) => false,
  //     );
  //   }
  // }

  Future<void> _saveProfile(AuthService authService, String uid) async {
    await authService.updateProfile(
      uid: uid,
      name: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      college: _collegeController.text.trim().isNotEmpty
          ? _collegeController.text.trim()
          : null,
      branch: _selectedBranch,
      year: _selectedYear,
    );
    setState(() => _isEditMode = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated! ✅')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final doubtService = context.read<DoubtService>();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: AppTheme.bgPrimary,
        body: Center(child: Text('Please log in')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: StreamBuilder<UserModel?>(
        stream: authService.userDataStream(currentUser.uid),
        builder: (context, snapshot) {
          final userData = snapshot.data;
          if (userData != null && !_isEditMode) {
            _nameController.text = userData.name;
            _collegeController.text = userData.college ?? '';
            _selectedBranch = userData.branch;
            _selectedYear = userData.year;
          }

          return NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverToBoxAdapter(
                child: _buildProfileHeader(context, userData, authService, currentUser),
              ),
              SliverToBoxAdapter(
                child: _buildStatsRow(userData),
              ),
              SliverToBoxAdapter(
                child: _buildTabBar(),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // My Doubts Tab
                _buildMyDoubts(doubtService, currentUser.uid),
                // Info Tab
                _buildInfoTab(userData, authService, currentUser.uid),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserModel? userData,
    AuthService authService,
    User currentUser,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0A35), AppTheme.bgPrimary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isEditMode = !_isEditMode),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Icon(
                        _isEditMode ? Icons.close : Icons.edit_outlined,
                        size: 18,
                        color: AppTheme.neonPurple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showLogoutDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Avatar
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: AppTheme.neonShadow,
                ),
                child: userData?.photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: Image.network(userData!.photoUrl!,
                            fit: BoxFit.cover),
                      )
                    : Center(
                        child: Text(
                          (userData?.name ?? 'U')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              // Online indicator
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.bgPrimary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isEditMode)
            _buildEditNameField()
          else ...[
            Text(
              userData?.name ?? currentUser.displayName ?? 'User',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentUser.email ?? '',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            // Branch & Year badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBadge(
                    userData?.branch ?? 'CSE', AppTheme.neonPurple),
                const SizedBox(width: 8),
                _buildBadge(userData?.year ?? '1st Year',
                    AppTheme.neonBlue),
              ],
            ),
          ],
          if (_isEditMode) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _saveProfile(authService, currentUser.uid),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.neonShadow,
                ),
                child: Text(
                  'Save Changes',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditNameField() {
    return SizedBox(
      width: 240,
      child: TextField(
        controller: _nameController,
        textAlign: TextAlign.center,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Your name',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          filled: true,
          fillColor: AppTheme.bgCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.neonPurple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppTheme.neonPurple, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatsRow(UserModel? userData) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          _buildStatItem('${userData?.points ?? 0}', 'Points',
              Icons.star_rounded, AppTheme.neonPurple),
          _buildStatDivider(),
          _buildStatItem('${userData?.doubtsPosted ?? 0}', 'Doubts',
              Icons.help_outline_rounded, AppTheme.neonBlue),
          _buildStatDivider(),
          _buildStatItem('${userData?.answersGiven ?? 0}', 'Answers',
              Icons.check_circle_outline, Colors.green),
          _buildStatDivider(),
          _buildStatItem(
              '${userData?.badges.length ?? 0}',
              'Badges',
              Icons.military_tech_rounded,
              const Color(0xFFFFB030)),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.borderColor,
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textMuted,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        tabs: const [
          Tab(text: 'My Doubts'),
          Tab(text: 'Account Info'),
        ],
      ),
    );
  }

  Widget _buildMyDoubts(DoubtService doubtService, String userId) {
    return StreamBuilder<List<DoubtModel>>(
      stream: doubtService.getUserDoubts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.neonPurple),
          );
        }

        final doubts = snapshot.data ?? [];

        if (doubts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.help_outline, size: 52, color: AppTheme.textMuted),
                const SizedBox(height: 16),
                Text(
                  'No doubts posted yet',
                  style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Start posting your doubts!',
                  style: GoogleFonts.inter(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 100),
          itemCount: doubts.length,
          itemBuilder: (context, index) {
            return DoubtCard(
              doubt: doubts[index],
              currentUserId: userId,
              onUpvote: () =>
                  doubtService.upvoteDoubt(doubts[index].id, userId),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoTab(
      UserModel? userData, AuthService authService, String uid) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Personal Information'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildInfoRow(Icons.person_outline, 'Name', userData?.name ?? '-'),
            _buildInfoRow(Icons.email_outlined, 'Email',
                FirebaseAuth.instance.currentUser?.email ?? '-'),
          ]),
          const SizedBox(height: 20),
          _buildSectionHeader('Academic Details'),
          const SizedBox(height: 12),
          _isEditMode
              ? _buildEditFields(authService, uid)
              : _buildInfoCard([
                  _buildInfoRow(
                      Icons.school_outlined, 'College', userData?.college ?? '-'),
                  _buildInfoRow(
                      Icons.computer, 'Branch', userData?.branch ?? '-'),
                  _buildInfoRow(
                      Icons.calendar_today_outlined, 'Year', userData?.year ?? '-'),
                ]),
          const SizedBox(height: 20),
          _buildSectionHeader('Activity'),
          const SizedBox(height: 12),
          _buildInfoCard([
            _buildInfoRow(
              Icons.access_time,
              'Member Since',
              userData?.createdAt != null
                  ? '${userData!.createdAt.day}/${userData.createdAt.month}/${userData.createdAt.year}'
                  : '-',
            ),
            _buildInfoRow(
              Icons.login,
              'Last Login',
              userData?.lastLogin != null
                  ? '${userData!.lastLogin!.day}/${userData.lastLogin!.month}/${userData.lastLogin!.year}'
                  : '-',
            ),
          ]),
          const SizedBox(height: 20),
          if (userData?.badges.isNotEmpty == true) ...[
            _buildSectionHeader('Badges'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: userData!.badges.map((badge) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.neonShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.military_tech_rounded,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        badge,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditFields(AuthService authService, String uid) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          TextField(
            controller: _collegeController,
            style: GoogleFonts.inter(
                color: AppTheme.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'College',
              prefixIcon: const Icon(Icons.school_outlined,
                  size: 18, color: AppTheme.neonPurple),
            ),
          ),
          const SizedBox(height: 12),
          // Branch Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.bgPrimary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBranch ?? 'CSE',
                isExpanded: true,
                dropdownColor: AppTheme.bgCardHover,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppTheme.neonPurple, size: 20),
                items: _branches.map((b) {
                  return DropdownMenuItem(value: b, child: Text(b));
                }).toList(),
                onChanged: (v) => setState(() => _selectedBranch = v),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Year Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.bgPrimary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedYear ?? '1st Year',
                isExpanded: true,
                dropdownColor: AppTheme.bgCardHover,
                style: GoogleFonts.inter(
                    color: AppTheme.textPrimary, fontSize: 14),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppTheme.neonPurple, size: 20),
                items: _years.map((y) {
                  return DropdownMenuItem(value: y, child: Text(y));
                }).toList(),
                onChanged: (v) => setState(() => _selectedYear = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(children: rows),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.neonPurple),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Sign Out?',
        style: GoogleFonts.spaceGrotesk(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'Are you sure you want to sign out of StudyHive?',
        style: GoogleFonts.inter(
          color: AppTheme.textSecondary,
          fontSize: 14,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // _logout(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Sign Out',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}}