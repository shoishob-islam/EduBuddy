import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Notice extends StatefulWidget {
  final bool isCR;
  const Notice({super.key, required this.isCR});

  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.isCR ? 3 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notices"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(icon: Icon(Icons.notifications_active), text: "Active"),
            const Tab(icon: Icon(Icons.archive), text: "Archived"),
            if (widget.isCR) const Tab(icon: Icon(Icons.drafts), text: "Drafts"),
          ],
        ),
        actions: [
          if (widget.isCR)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddNoticeDialog(isDraft: false),
              tooltip: "Add Notice",
            ),
          if (widget.isCR)
            IconButton(
              icon: const Icon(Icons.drafts),
              onPressed: () => _showAddNoticeDialog(isDraft: true),
              tooltip: "Save as Draft",
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNoticeList(isActive: true, isArchived: false),
          _buildNoticeList(isActive: false, isArchived: true),
          if (widget.isCR) _buildNoticeList(isActive: false, isArchived: false, isDraft: true),
        ],
      ),
    );
  }

  Widget _buildNoticeList({
    required bool isActive,
    required bool isArchived,
    bool isDraft = false,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notices')
          .where('isDraft', isEqualTo: isDraft)
          .where('isActive', isEqualTo: isActive)
          .where('isArchived', isEqualTo: isArchived)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final notices = snapshot.data?.docs ?? [];

        if (notices.isEmpty) {
          String message = isDraft ? "No draft notices" :
          isArchived ? "No archived notices" :
          "No active notices";
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                if (!isArchived && !isDraft && widget.isCR)
                  const Text(
                    "Click + to add a notice",
                    style: TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notices.length,
          itemBuilder: (context, index) {
            var notice = notices[index];
            return NoticeCard(
              notice: notice,
              isCR: widget.isCR,
              isDraft: isDraft,
              onDelete: () => _deleteNotice(notice.id),
              onPublish: isDraft ? () => _publishDraft(notice.id) : null,
              onArchive: !isArchived && !isDraft && notice['isActive'] == true
                  ? () => _archiveNotice(notice.id)
                  : null,
              onRestore: isArchived ? () => _restoreNotice(notice.id) : null,
            );
          },
        );
      },
    );
  }

  void _showAddNoticeDialog({required bool isDraft}) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> uploadNotice() async {
            if (titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please enter a title")),
              );
              return;
            }

            setDialogState(() => isUploading = true);

            try {
              await FirebaseFirestore.instance.collection('notices').add({
                'title': titleController.text.trim(),
                'description': descriptionController.text.trim(),
                'createdBy': FirebaseAuth.instance.currentUser?.email,
                'createdAt': FieldValue.serverTimestamp(),
                'isActive': !isDraft,
                'isDraft': isDraft,
                'isArchived': false,
                'type': 'notice',
              });

              // Send email notifications if publishing
              if (!isDraft) {
                await _sendEmailNotifications(
                  titleController.text.trim(),
                  descriptionController.text.trim(),
                );
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isDraft ? "Draft saved!" : "Notice published!"),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            } finally {
              setDialogState(() => isUploading = false);
            }
          }

          return AlertDialog(
            title: Text(isDraft ? "Save as Draft" : "Add New Notice"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title *",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isUploading ? null : uploadNotice,
                child: isUploading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(isDraft ? "Save Draft" : "Publish"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _sendEmailNotifications(String title, String description) async {
    try {
      QuerySnapshot users = await FirebaseFirestore.instance
          .collection('users')
          .where('isCR', isEqualTo: false)
          .get();

      List<String> emails = users.docs.map((doc) => doc['email'] as String).toList();

      print("Sending email to ${emails.length} students about: $title");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Email notification would be sent to ${emails.length} students"),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print("Error sending emails: $e");
    }
  }

  Future<void> _deleteNotice(String noticeId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Notice"),
        content: const Text("Are you sure you want to delete this notice?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection('notices').doc(noticeId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notice deleted!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> _publishDraft(String draftId) async {
    try {
      await FirebaseFirestore.instance.collection('notices').doc(draftId).update({
        'isDraft': false,
        'isActive': true,
        'publishedAt': FieldValue.serverTimestamp(),
      });

      DocumentSnapshot draft = await FirebaseFirestore.instance.collection('notices').doc(draftId).get();
      await _sendEmailNotifications(
        draft['title'],
        draft['description'] ?? '',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Draft published!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _archiveNotice(String noticeId) async {
    try {
      await FirebaseFirestore.instance.collection('notices').doc(noticeId).update({
        'isActive': false,
        'isArchived': true,
        'archivedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notice archived!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _restoreNotice(String noticeId) async {
    try {
      await FirebaseFirestore.instance.collection('notices').doc(noticeId).update({
        'isArchived': false,
        'isActive': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notice restored!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}

//  NOTICE CARD
class NoticeCard extends StatelessWidget {
  final QueryDocumentSnapshot notice;
  final bool isCR;
  final bool isDraft;
  final VoidCallback onDelete;
  final VoidCallback? onPublish;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;

  const NoticeCard({
    super.key,
    required this.notice,
    required this.isCR,
    required this.isDraft,
    required this.onDelete,
    this.onPublish,
    this.onArchive,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = (notice['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    notice['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    // Draft Badge
                    if (isDraft)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Draft",
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
// Delete Button
                    if (isCR)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: onDelete,
                        tooltip: "Delete",
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

 // Description
            if (notice['description'] != null &&
                notice['description'].toString().isNotEmpty)
              Text(
                notice['description'],
                style: const TextStyle(fontSize: 14),
              ),

            const SizedBox(height: 12),

// Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMd().add_jm().format(createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
// Action Buttons for Drafts/Archived
            if (isCR) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onPublish != null)
                    ElevatedButton.icon(
                      onPressed: onPublish,
                      icon: const Icon(Icons.publish, size: 16),
                      label: const Text("Publish"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (onArchive != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: OutlinedButton.icon(
                        onPressed: onArchive,
                        icon: const Icon(Icons.archive, size: 16),
                        label: const Text("Archive"),
                      ),
                    ),
                  if (onRestore != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: OutlinedButton.icon(
                        onPressed: onRestore,
                        icon: const Icon(Icons.unarchive, size: 16),
                        label: const Text("Restore"),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}