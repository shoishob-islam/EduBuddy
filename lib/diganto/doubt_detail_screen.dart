import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'doubt_model.dart';
import 'answer_model.dart';
import 'doubt_service.dart';
import 'auth_service.dart';
import 'app_theme.dart';

class DoubtDetailScreen extends StatefulWidget {
  final DoubtModel doubt;
  const DoubtDetailScreen({super.key, required this.doubt});

  @override
  State<DoubtDetailScreen> createState() => _DoubtDetailScreenState();
}

class _DoubtDetailScreenState extends State<DoubtDetailScreen> {
  final _answerController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _postAnswer(
    DoubtService service,
    String userId,
    String userName,
    String? photoUrl,
    int points,
  ) async {
    if (_answerController.text.trim().isEmpty) return;
    setState(() => _isPosting = true);

    final success = await service.postAnswer(
      doubtId: widget.doubt.id,
      userId: userId,
      userName: userName,
      userPhotoUrl: photoUrl,
      content: _answerController.text.trim(),
      userPoints: points,
    );

    if (success && mounted) {
      _answerController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer posted! +10 points 🎉')),
      );
    }
    if (mounted) setState(() => _isPosting = false);
  }

  @override
  Widget build(BuildContext context) {
    final doubtService = DoubtService();
    final authService = AuthService();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppTheme.textPrimary),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Doubt',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          if (widget.doubt.isResolved)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Resolved',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildDoubtContent(
                      doubtService, currentUser?.uid ?? ''),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 18,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        StreamBuilder<List<AnswerModel>>(
                          stream:
                              doubtService.getAnswers(widget.doubt.id),
                          builder: (context, snapshot) {
                            final count = snapshot.data?.length ?? 0;
                            return Text(
                              '$count Answers',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                _buildAnswersList(doubtService, currentUser?.uid ?? ''),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          _buildAnswerInput(doubtService, authService, currentUser),
        ],
      ),
    );
  }

  // ── DOUBT CONTENT ──────────────────────────────────────────────
  Widget _buildDoubtContent(
      DoubtService doubtService, String currentUserId) {
    final doubt = widget.doubt;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    doubt.subjectColor.withValues(alpha: 0.2),
                backgroundImage: doubt.userPhotoUrl != null
                    ? NetworkImage(doubt.userPhotoUrl!)
                    : null,
                child: doubt.userPhotoUrl == null
                    ? Text(
                        doubt.userName.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          color: doubt.subjectColor,
                          fontSize: 15,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doubt.userName,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      timeago.format(doubt.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Subject Badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: doubt.subjectColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: doubt.subjectColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  doubt.subjectLabel,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: doubt.subjectColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.dividerColor),
          const SizedBox(height: 14),

          // Title
          Text(
            doubt.title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          if (doubt.description.isNotEmpty)
            Text(
              doubt.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.65,
              ),
            ),

          // Image
          if (doubt.imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                doubt.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: AppTheme.bgCardHover,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.neonPurple, strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
          ],

          // Tags
          if (doubt.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: doubt.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.bgPrimary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text(
                    '#$tag',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 20),
          const Divider(color: AppTheme.dividerColor),
          const SizedBox(height: 12),

          // Action Row
          Row(
            children: [
              _buildActionBtn(
                icon: doubt.upvotedBy.contains(currentUserId)
                    ? Icons.thumb_up
                    : Icons.thumb_up_outlined,
                label: '${doubt.upvotes}',
                color: doubt.upvotedBy.contains(currentUserId)
                    ? AppTheme.neonPurple
                    : AppTheme.textMuted,
                onTap: () =>
                    doubtService.upvoteDoubt(doubt.id, currentUserId),
              ),
              const SizedBox(width: 16),
              _buildActionBtn(
                icon: Icons.chat_bubble_outline_rounded,
                label: '${doubt.answersCount} answers',
                color: AppTheme.textMuted,
                onTap: null,
              ),
              const Spacer(),
              _buildActionBtn(
                icon: Icons.share_outlined,
                label: 'Share',
                color: AppTheme.textMuted,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── ANSWERS LIST ───────────────────────────────────────────────
  Widget _buildAnswersList(
      DoubtService doubtService, String currentUserId) {
    return StreamBuilder<List<AnswerModel>>(
      stream: doubtService.getAnswers(widget.doubt.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                    color: AppTheme.neonPurple),
              ),
            ),
          );
        }

        final answers = snapshot.data ?? [];

        if (answers.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(Icons.forum_outlined,
                        size: 52, color: AppTheme.textMuted),
                    const SizedBox(height: 14),
                    Text(
                      'No answers yet',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Be the first to help!',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textMuted,
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
              final answer = answers[index];
              return _buildAnswerCard(
                  answer, doubtService, currentUserId);
            },
            childCount: answers.length,
          ),
        );
      },
    );
  }

  Widget _buildAnswerCard(AnswerModel answer, DoubtService doubtService,
      String currentUserId) {
    final isOwner = widget.doubt.userId == currentUserId;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: answer.isAccepted
            ? const Color(0xFF0D2A1A)
            : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: answer.isAccepted
              ? Colors.green.withValues(alpha: 0.4)
              : AppTheme.borderColor,
        ),
        boxShadow: answer.isAccepted
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.08),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor:
                    AppTheme.neonPurple.withValues(alpha: 0.2),
                backgroundImage: answer.userPhotoUrl != null
                    ? NetworkImage(answer.userPhotoUrl!)
                    : null,
                child: answer.userPhotoUrl == null
                    ? Text(
                        answer.userName.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.neonPurple,
                          fontSize: 13,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          answer.userName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (answer.userPoints > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.neonPurple
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${answer.userPoints} pts',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: AppTheme.neonPurpleLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      timeago.format(answer.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (answer.isAccepted)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Accepted',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            answer.content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.65,
            ),
          ),

          if (answer.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                answer.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(color: AppTheme.dividerColor, height: 1),
          const SizedBox(height: 10),

          Row(
            children: [
              GestureDetector(
                onTap: () => doubtService.upvoteAnswer(
                    widget.doubt.id, answer.id, currentUserId),
                child: Row(
                  children: [
                    Icon(
                      answer.upvotedBy.contains(currentUserId)
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      size: 15,
                      color: answer.upvotedBy.contains(currentUserId)
                          ? AppTheme.neonPurple
                          : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${answer.upvotes}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: answer.upvotedBy.contains(currentUserId)
                            ? AppTheme.neonPurple
                            : AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isOwner &&
                  !answer.isAccepted &&
                  !widget.doubt.isResolved)
                GestureDetector(
                  onTap: () => doubtService.acceptAnswer(
                      widget.doubt.id, answer.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.green.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check,
                            color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Accept',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ANSWER INPUT ───────────────────────────────────────────────
  Widget _buildAnswerInput(
    DoubtService doubtService,
    AuthService authService,
    User? currentUser,
  ) {
    return FutureBuilder(
      future: currentUser != null
          ? authService.getUserData(currentUser.uid)
          : Future.value(null),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.bgSecondary,
            border: Border(
              top: BorderSide(color: AppTheme.borderColor),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    AppTheme.neonPurple.withValues(alpha: 0.2),
                child: Text(
                  (userData?.name ??
                          currentUser?.displayName ??
                          'U')
                      .substring(0, 1)
                      .toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.neonPurple,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                    controller: _answerController,
                    maxLines: null,
                    style: GoogleFonts.inter(
                        color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Write your answer...',
                      hintStyle: GoogleFonts.inter(
                          color: AppTheme.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: AppTheme.bgCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppTheme.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppTheme.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppTheme.neonPurple, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _isPosting
                    ? null
                    : () => _postAnswer(
                          doubtService,
                          currentUser?.uid ?? '',
                          userData?.name ??
                              currentUser?.displayName ??
                              'User',
                          userData?.photoUrl,
                          userData?.points ?? 0,
                        ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient:
                        _isPosting ? null : AppTheme.primaryGradient,
                    color: _isPosting ? AppTheme.bgCard : null,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow:
                        _isPosting ? null : AppTheme.neonShadow,
                  ),
                  child: Center(
                    child: _isPosting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: AppTheme.neonPurple,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}