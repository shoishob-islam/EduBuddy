import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CRDashboard extends StatefulWidget {
  final String? currentCREmail;
  const CRDashboard({super.key, this.currentCREmail});

  @override
  State<CRDashboard> createState() => _CRDashboardState();
}

class _CRDashboardState extends State<CRDashboard> {
  final TextEditingController _emailController = TextEditingController();
  bool _isTransferring = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CR Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFF3E0), Colors.white, const Color(0xFFFFE0B5),
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('isCR', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            var crs = snapshot.data?.docs ?? [];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
// Current CR Info Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),

                                child: const Icon(
                                  Icons.crop,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Current Class Representative",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (crs.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "No CR assigned",
                                style: TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            )
                          else
                            ...crs.map((cr) {
                              try {
                                var data = cr.data() as Map<String, dynamic>;
                                var email = data['email'] ?? 'Unknown';

                                String crSinceText = "Current CR";
                                if (data.containsKey('becameCRAt') && data['becameCRAt'] != null) {
                                  var becameAtValue = data['becameCRAt'];
                                  if (becameAtValue is Timestamp) {
                                    DateTime becameAt = becameAtValue.toDate();
                                    crSinceText = "CR since: ${DateFormat.yMMMd().format(becameAt)}";
                                  }
                                } else if (data.containsKey('createdAt') && data['createdAt'] != null) {
                                  var createdAtValue = data['createdAt'];
                                  if (createdAtValue is Timestamp) {
                                    DateTime createdAt = createdAtValue.toDate();
                                    crSinceText = "CR from: ${DateFormat.yMMMd().format(createdAt)}";
                                  }
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFFEF3C7),
                                        const Color(0xFFFDE68A),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          email.isNotEmpty ? email[0].toUpperCase() : "?",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              email,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Color(0xFF92400E),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              crSinceText,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: const Color(0xFFB45309),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (email == widget.currentCREmail)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(

                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            "You",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              } catch (e) {
                                return const SizedBox.shrink();
                              }
                            }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
// Transfer CR Role Section
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(

                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.swap_horiz,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Transfer CR Role",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Enter the email of the new Class Representative",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 20),

                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "New CR Email",
                              hintText: "example@email.com",
                              prefixIcon: const Icon(Icons.email, color: Color(0xFFF59E0B)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber, color: const Color(0xFFD97706), size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Current CR will lose their privileges. Only one CR can exist at a time.",
                                    style: TextStyle(
                                      color: const Color(0xFF92400E),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isTransferring ? null : _transferCRRole,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF59E0B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: _isTransferring
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Text(
                                "Transfer CR Role",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // CR History Section
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "CR Transfer History",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('cr_history')
                        .orderBy('timestamp', descending: true)
                        .limit(20)
                        .snapshots(),
                    builder: (context, historySnapshot) {
                      if (historySnapshot.hasError) {
                        return Center(child: Text('Error: ${historySnapshot.error}'));
                      }

                      if (historySnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var history = historySnapshot.data?.docs ?? [];

                      if (history.isEmpty) {
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                "No transfer history yet",
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          try {
                            var record = history[index];
                            var data = record.data() as Map<String, dynamic>;

                            var timestamp = data['timestamp'] as Timestamp?;
                            var newCR = data['newCR'] ?? 'Unknown';
                            var oldCR = data['oldCR'] ?? 'Unknown';
                            var changedBy = data['changedBy'] ?? 'Unknown';

                            String timeText = "Unknown date";
                            if (timestamp != null) {
                              DateTime date = timestamp.toDate();
                              timeText = DateFormat.yMMMd().add_jm().format(date);
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFFEF3C7),
                                  child: const Icon(Icons.swap_horiz, size: 18, color: Color(0xFFF59E0B)),
                                ),
                                title: Text(
                                  "$oldCR → $newCR",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF92400E),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                subtitle: Text(
                                  timeText,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                trailing: Text(
                                  "by $changedBy",
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ),
                            );
                          } catch (e) {
                            return const SizedBox.shrink();
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _transferCRRole() async {
    String newCREmail = _emailController.text.trim();

    if (newCREmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an email address")),
      );
      return;
    }

    if (!newCREmail.contains('@') || !newCREmail.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    if (newCREmail == widget.currentCREmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This is already the current CR")),
      );
      return;
    }

    setState(() => _isTransferring = true);

    try {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: newCREmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("User not found. They need to login first."),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isTransferring = false);
        return;
      }

      QuerySnapshot currentCRQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('isCR', isEqualTo: true)
          .get();

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in currentCRQuery.docs) {
        batch.update(doc.reference, {'isCR': false});
      }

      batch.update(userQuery.docs[0].reference, {
        'isCR': true,
        'becameCRAt': FieldValue.serverTimestamp(),
      });

      DocumentReference historyRef = FirebaseFirestore.instance
          .collection('cr_history')
          .doc();

      batch.set(historyRef, {
        'newCR': newCREmail,
        'oldCR': widget.currentCREmail ?? 'unknown',
        'changedBy': FirebaseAuth.instance.currentUser?.email ?? 'unknown',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        _emailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("CR role transferred to $newCREmail successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error transferring CR role: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTransferring = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}