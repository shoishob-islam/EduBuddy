import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'notification_service.dart';
import 'app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  IconData _getIcon(String type) {
    switch (type) {
      case 'answer':
        return Icons.question_answer_rounded;
      case 'upvote':
        return Icons.thumb_up_rounded;
      case 'accept':
        return Icons.check_circle_rounded;
      case 'community':
        return Icons.group_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'answer':
        return AppTheme.neonPurple;
      case 'upvote':
        return const Color(0xFF30AAFF);
      case 'accept':
        return Colors.green;
      case 'community':
        return const Color(0xFFFF30AA);
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifService = context.read<NotificationService>();
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
          'Notifications',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (currentUser != null) {
                notifService.markAllAsRead(currentUser.uid);
              }
            },
            child: Text(
              'Mark all read',
              style: GoogleFonts.inter(
                color: AppTheme.neonPurple,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('Please login'))
          : StreamBuilder<List<NotificationItem>>(
              stream: notifService.getNotifications(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.neonPurple),
                  );
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: const Icon(
                            Icons.notifications_off_outlined,
                            size: 36,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No notifications yet',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Post doubts and get answers\nto receive notifications.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: AppTheme.dividerColor, height: 1),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return GestureDetector(
                      onTap: () {
                        notifService.markAsRead(notif.id);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        color: notif.isRead
                            ? Colors.transparent
                            : AppTheme.neonPurple.withOpacity(0.04),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _getColor(notif.type).withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      _getColor(notif.type).withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                _getIcon(notif.type),
                                color: _getColor(notif.type),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notif.title,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 14,
                                      fontWeight: notif.isRead
                                          ? FontWeight.w500
                                          : FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif.body,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    timeago.format(notif.createdAt),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!notif.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonPurple,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppTheme.neonPurple.withOpacity(0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
