import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Voting extends StatefulWidget {
  final bool isCR;
  const Voting({super.key, required this.isCR});

  @override
  State<Voting> createState() => _VotingState();
}

class _VotingState extends State<Voting> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isCR ? 3 : 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voting & Polls"),
        bottom: TabBar(
          controller: _tabController,
          tabs: widget.isCR
              ? const [
            Tab(icon: Icon(Icons.how_to_vote), text: "Active Polls"),
            Tab(icon: Icon(Icons.history), text: "Past Results"),
            Tab(icon: Icon(Icons.add_chart), text: "Create Poll"),
          ]
              : const [
            Tab(icon: Icon(Icons.how_to_vote), text: "Active Polls"),
            Tab(icon: Icon(Icons.history), text: "Past Results"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.isCR
            ? [
          const ActivePollsTab(),
          const PastResultsTab(),
          CreatePollTab(isCR: widget.isCR),
        ]
            : const [
          ActivePollsTab(),
          PastResultsTab(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ACTIVE POLLS TAB
class ActivePollsTab extends StatelessWidget {
  const ActivePollsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('polls')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final polls = snapshot.data?.docs ?? [];

        if (polls.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.how_to_vote, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No Active Polls",
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                Text("Create a poll to get started!"),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: polls.length,
          itemBuilder: (context, index) {
            return PollCard(poll: polls[index]);
          },
        );
      },
    );
  }
}

//POLL CARD
class PollCard extends StatefulWidget {
  final QueryDocumentSnapshot poll;
  const PollCard({super.key, required this.poll});

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  String? selectedOption;
  bool hasVoted = false;
  bool isLoading = false;
  bool isEnding = false;
  DateTime? endDate;
  bool hasEndDate = false;
  bool isExpired = false;
  Duration? timeLeft;

  @override
  void initState() {
    super.initState();
    _checkVotedStatus();
    _checkEndDate();
    _checkAndMoveExpiredPoll();
  }

  Future<void> _checkAndMoveExpiredPoll() async {
    if (hasEndDate && isExpired && widget.poll['isActive'] == true) {
      try {
        await FirebaseFirestore.instance
            .collection('polls')
            .doc(widget.poll.id)
            .update({
          'isActive': false,
          'expiredAutomatically': true,
          'expiredAt': FieldValue.serverTimestamp(),
        });
        print("Poll ${widget.poll['title']} automatically moved to past results");
      } catch (e) {
        print("Error moving expired poll: $e");
      }
    }
  }
  void _checkVotedStatus() {
    final voters = widget.poll['voters'] as List? ?? [];
    hasVoted = voters.contains(FirebaseAuth.instance.currentUser?.uid);
  }

  void _checkEndDate() {
    try {
      final data = widget.poll.data() as Map<String, dynamic>;
      if (data.containsKey('endDate') && data['endDate'] != null) {
        final timestamp = data['endDate'] as Timestamp;
        endDate = timestamp.toDate();
        hasEndDate = true;
        timeLeft = endDate!.difference(DateTime.now());
        isExpired = timeLeft!.isNegative;
      }
    } catch (e) {
      hasEndDate = false;
    }
  }

  String _formatTimeLeft() {
    if (!hasEndDate) return "No expiry";
    if (timeLeft == null) return "No expiry";
    if (timeLeft!.inDays > 0) return "${timeLeft!.inDays} days left";
    if (timeLeft!.inHours > 0) return "${timeLeft!.inHours} hours left";
    if (timeLeft!.inMinutes > 0) return "${timeLeft!.inMinutes} minutes left";
    return "Ending soon";
  }

  Color _getTimerColor() {
    if (!hasEndDate) return Colors.grey;
    if (timeLeft == null) return Colors.grey;
    return timeLeft!.inHours < 24 ? Colors.orange : Colors.green;
  }

  Color _getTimerBackgroundColor() {
    if (!hasEndDate) return Colors.grey.shade100;
    if (timeLeft == null) return Colors.grey.shade100;
    return timeLeft!.inHours < 24 ? Colors.orange.shade50 : Colors.green.shade50;
  }

  Future<void> _endPoll() async {
    setState(() => isEnding = true);

    try {
      await FirebaseFirestore.instance
          .collection('polls')
          .doc(widget.poll.id)
          .update({
        'isActive': false,
        'endedManually': true,
        'endedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Poll ended successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error ending poll: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isEnding = false);
    }
  }

  Future<void> _castVote() async {
    if (selectedOption == null) return;
    setState(() => isLoading = true);

    try {
      final options = widget.poll['options'] as List;
      final optionIndex = options.indexOf(selectedOption);
      final pollRef = FirebaseFirestore.instance.collection('polls').doc(widget.poll.id);
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final freshPoll = await transaction.get(pollRef);
        if (!freshPoll.exists) return;

        final currentVotes = List.from(freshPoll['votes'] ?? List.filled(options.length, 0));
        if (optionIndex < currentVotes.length) {
          currentVotes[optionIndex] = (currentVotes[optionIndex] as int) + 1;
        }

        final voters = List.from(freshPoll['voters'] ?? []);
        voters.add(userId);

        transaction.update(pollRef, {
          'votes': currentVotes,
          'voters': voters,
        });
      });

      if (mounted) {
        setState(() {
          hasVoted = true;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vote cast successfully!")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error casting vote: $e")),
      );
    }
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.amber,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.poll['options'] as List;
    final votes = widget.poll['votes'] as List? ?? List.filled(options.length, 0);
    final totalVotes = votes.fold<int>(0, (sum, v) => sum + (v as int));
    final createdAt = (widget.poll['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final isCR = widget.poll['createdBy'] == FirebaseAuth.instance.currentUser?.email;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.poll['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // Description
            if (widget.poll['description'] != null) ...[
              const SizedBox(height: 8),
              Text(widget.poll['description']),
            ],

            const SizedBox(height: 12),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isExpired
                    ? Colors.red.shade50
                    : _getTimerBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isExpired
                        ? Icons.warning_amber
                        : hasEndDate
                        ? Icons.timer
                        : Icons.timer_off,
                    size: 14,
                    color: isExpired
                        ? Colors.red
                        : _getTimerColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isExpired ? "Expired" : _formatTimeLeft(),
                    style: TextStyle(
                      color: isExpired ? Colors.red : _getTimerColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  "Created: ${DateFormat.yMMMd().format(createdAt)}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Options
            if (!hasVoted && !isExpired)
              Column(
                children: List.generate(options.length, (i) {
                  final isSelected = selectedOption == options[i].toString();
                  return GestureDetector(
                    onTap: () => setState(() => selectedOption = options[i].toString()),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                              ),
                            )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            options[i].toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                              color: isSelected ? Colors.blue.shade900 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              )
            else
              ...List.generate(options.length, (i) {
                final voteCount = i < votes.length ? votes[i] as int : 0;
                final percentage = totalVotes > 0 ? (voteCount / totalVotes * 100) : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(options[i].toString()),
                          Text("$voteCount votes"),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(_getColorForIndex(i)),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${percentage.toStringAsFixed(1)}%",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                if (!hasVoted && !isExpired)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (selectedOption == null || isLoading) ? null : _castVote,
                      child: isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text("Cast Vote"),
                    ),
                  ),
                if (hasVoted && !isExpired)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text("You've voted"),
                        ],
                      ),
                    ),
                  ),
                if (isExpired)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_off, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Poll expired"),
                        ],
                      ),
                    ),
                  ),
                if (isCR && !isExpired && !hasVoted)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: isEnding
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.close, color: Colors.red),
                      onPressed: isEnding ? null : _endPoll,
                      tooltip: "End Poll Manually",
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                "Total votes: $totalVotes",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PAST RESULTS TAB
class PastResultsTab extends StatelessWidget {
  const PastResultsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('polls')
          .where('isActive', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final polls = snapshot.data?.docs ?? [];

        if (polls.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No Past Polls",
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: polls.length,
          itemBuilder: (context, index) {
            return PastPollCard(poll: polls[index]);
          },
        );
      },
    );
  }
}

//  PAST POLL CARD
class PastPollCard extends StatelessWidget {
  final QueryDocumentSnapshot poll;
  const PastPollCard({super.key, required this.poll});

  @override
  Widget build(BuildContext context) {
    final options = poll['options'] as List;
    final votes = poll['votes'] as List? ?? [];
    final totalVotes = votes.fold<int>(0, (sum, v) => sum + (v as int));
    final createdAt = (poll['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final endDate = (poll['endDate'] as Timestamp?)?.toDate();

    bool endedManually = false;
    final data = poll.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey('endedManually')) {
      endedManually = data['endedManually'] as bool? ?? false;
    }

// Find winner(s)
    int maxVotes = 0;
    for (final v in votes) {
      if (v > maxVotes) maxVotes = v as int;
    }
    final winnerIndices = <int>[];
    for (int i = 0; i < votes.length; i++) {
      if (votes[i] == maxVotes) winnerIndices.add(i);
    }
    final winners = winnerIndices.map((i) => options[i].toString()).join(' & ');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poll['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(poll['description'] ?? ''),
            const SizedBox(height: 12),

// Winner announcement
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Winner: $winners",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total votes: $totalVotes"),
                if (endedManually)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Ended Manually",
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Created: ${DateFormat.yMMMd().format(createdAt)}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (endDate != null)
                  Text(
                    "Ended: ${DateFormat.yMMMd().format(endDate)}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () => _showDetails(context),
              child: const Text("View Details"),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, controller) {
            final options = poll['options'] as List;
            final votes = poll['votes'] as List? ?? [];
            final totalVotes = votes.fold<int>(0, (sum, v) => sum + (v as int));

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Poll Results",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    poll['title'],
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: options.length,
                      itemBuilder: (context, i) {
                        final voteCount = i < votes.length ? votes[i] as int : 0;
                        final percentage = totalVotes > 0 ? (voteCount / totalVotes * 100) : 0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(options[i].toString()),
                            trailing: Text("$voteCount votes"),
                            subtitle: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

//  CREATE POLL TAB
class CreatePollTab extends StatefulWidget {
  final bool isCR;
  const CreatePollTab({super.key, required this.isCR});

  @override
  State<CreatePollTab> createState() => _CreatePollTabState();
}

class _CreatePollTabState extends State<CreatePollTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  DateTime? _endDate;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _addOption();
    _addOption();
  }

  void _addOption() {
    if (_optionControllers.length < 5) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null || !mounted) return;

    setState(() {
      _endDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _createPoll() async {
    if (!_formKey.currentState!.validate()) return;

    final options = _optionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least 2 options")),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final pollData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'options': options,
        'votes': List.filled(options.length, 0),
        'voters': [],
        'createdBy': FirebaseAuth.instance.currentUser?.email,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      if (_endDate != null) {
        pollData['endDate'] = Timestamp.fromDate(_endDate!);
      }

      await FirebaseFirestore.instance.collection('polls').add(pollData);

      if (mounted) {
        _titleController.clear();
        _descriptionController.clear();
        for (var c in _optionControllers) {
          c.clear();
        }
        setState(() => _endDate = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Poll created successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isCR) {
      return const Center(
        child: Text("You don't have permission to create polls"),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Create New Poll",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: "Poll Title",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            validator: (v) => v?.isEmpty == true ? "Enter a title" : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: "Description (Optional)",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 2,
            child: ListTile(
              title: const Text("Poll End Date (Optional)"),
              subtitle: Text(
                _endDate == null
                    ? "Leave blank for no expiry"
                    : "Ends: ${DateFormat.yMMMd().add_jm().format(_endDate!)}",
              ),
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              trailing: _endDate != null
                  ? IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () => setState(() => _endDate = null),
              )
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _selectEndDate,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            "Options",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ...List.generate(_optionControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _optionControllers[i],
                      decoration: InputDecoration(
                        hintText: "Option ${i + 1}",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.radio_button_unchecked),
                      ),
                      validator: (v) => v?.isEmpty == true ? "Required" : null,
                    ),
                  ),
                  if (_optionControllers.length > 2)
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeOption(i),
                    ),
                ],
              ),
            );
          }),

          if (_optionControllers.length < 5)
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              label: const Text("Add Option"),
            ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _isCreating ? null : _createPoll,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
            child: _isCreating
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text("Create Poll", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }
}