import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationItem {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'answer', 'upvote', 'accept', 'community'
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map, String id) {
    return NotificationItem(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'general',
      relatedId: map['relatedId'],
      isRead: map['isRead'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'relatedId': relatedId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Stream<List<NotificationItem>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationItem.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    final notification = NotificationItem(
      id: '',
      userId: userId,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('notifications').add(notification.toMap());

    // Send push notification
    await _sendPushNotification(userId, title, body);
  }

  Future<void> _sendPushNotification(
      String userId, String title, String body) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final token = userDoc.data()?['fcmToken'] as String?;
        if (token != null) {
          debugPrint('Would send push notification to token: $token');
          debugPrint('Title: $title');
          debugPrint('Body: $body');
        }
      }
    } catch (e, st) {
      debugPrint('Error sending push notification: $e');
      debugPrint(st.toString());
    }
  }

  Future<void> saveDeviceToken(String userId) async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
        });
      }
    } catch (e, st) {
      debugPrint('Error saving device token: $e');
      debugPrint(st.toString());
    }
  }

  Future<void> initializeNotifications() async {
    await _firebaseMessaging.requestPermission();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.notification?.title}');
    });
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}
