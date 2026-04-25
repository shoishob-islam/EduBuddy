import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doubt_model.dart';
import 'app_theme.dart';
import 'doubt_detail_screen.dart';
 
class DoubtCard extends StatelessWidget {
  final DoubtModel doubt;
  final String currentUserId;
  final VoidCallback onUpvote;
 
  const DoubtCard({
    super.key,
    required this.doubt,
    required this.currentUserId,
    required this.onUpvote,
  });
 
  @override
  Widget build(BuildContext context) {
    final hasUpvoted = doubt.upvotedBy.contains(currentUserId);
    final color = doubt.subjectColor;
 
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                DoubtDetailScreen(doubt: doubt),
            transitionsBuilder:
                (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: doubt.isResolved
                ? Colors.green.withValues(alpha: 0.25)
                : AppTheme.borderColor,
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withValues(alpha: 0.2),
                  backgroundImage: doubt.userPhotoUrl != null
                      ? NetworkImage(doubt.userPhotoUrl!)
                      : null,
                  child: doubt.userPhotoUrl == null
                      ? Text(
                          doubt.userName.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w700,
                            color: color,
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doubt.userName,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        timeago.format(doubt.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Subject chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    doubt.subjectLabel,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                if (doubt.isResolved) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 16),
                ],
              ],
            ),
            const SizedBox(height: 12),
 
            // Title
            Text(
              doubt.title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
 
            // Description
            if (doubt.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                doubt.description,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
 
            // Image preview
            if (doubt.imageUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  doubt.imageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 140,
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
 
            // Input type badge
            if (doubt.inputType != DoubtInputType.text) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    doubt.inputType == DoubtInputType.image
                        ? Icons.photo_camera
                        : Icons.mic,
                    size: 12,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    doubt.inputType == DoubtInputType.image
                        ? 'Image question'
                        : 'Voice question',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
 
            // Tags
            if (doubt.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 5,
                children: doubt.tags.take(3).map((tag) {
                  return Text(
                    '#$tag',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.neonPurple.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ],
 
            const SizedBox(height: 12),
            const Divider(color: AppTheme.dividerColor, height: 1),
            const SizedBox(height: 10),
 
            // Footer
            Row(
              children: [
                GestureDetector(
                  onTap: onUpvote,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: hasUpvoted
                          ? AppTheme.neonPurple.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasUpvoted
                            ? AppTheme.neonPurple.withValues(alpha: 0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasUpvoted
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined,
                          size: 14,
                          color: hasUpvoted
                              ? AppTheme.neonPurple
                              : AppTheme.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${doubt.upvotes}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: hasUpvoted
                                ? AppTheme.neonPurple
                                : AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Real-time answer count
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('doubts')
                      .doc(doubt.id)
                      .collection('answers')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count =
                        snapshot.data?.docs.length ?? doubt.answersCount;
                    return Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline,
                            size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 5),
                        Text(
                          '$count answers',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),
                Text(
                  'View →',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppTheme.neonPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}