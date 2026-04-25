import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';

enum DoubtSubject { cse, physics, chemistry, eee, english, mathematics, other }

enum DoubtInputType { text, image, voice }

class DoubtModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String title;
  final String description;
  final DoubtSubject subject;
  final DoubtInputType inputType;
  final String? imageUrl;
  final String? audioUrl;
  final int answersCount;
  final int upvotes;
  final List<String> upvotedBy;
  final bool isResolved;
  final DateTime createdAt;
  final List<String> tags;

  DoubtModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.title,
    required this.description,
    required this.subject,
    this.inputType = DoubtInputType.text,
    this.imageUrl,
    this.audioUrl,
    this.answersCount = 0,
    this.upvotes = 0,
    this.upvotedBy = const [],
    this.isResolved = false,
    required this.createdAt,
    this.tags = const [],
  });

  factory DoubtModel.fromMap(Map<String, dynamic> map, String id) {
    return DoubtModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: DoubtSubject.values.firstWhere(
        (e) => e.name == map['subject'],
        orElse: () => DoubtSubject.other,
      ),
      inputType: DoubtInputType.values.firstWhere(
        (e) => e.name == map['inputType'],
        orElse: () => DoubtInputType.text,
      ),
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      answersCount: map['answersCount'] ?? 0,
      upvotes: map['upvotes'] ?? 0,
      upvotedBy: List<String>.from(map['upvotedBy'] ?? []),
      isResolved: map['isResolved'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'title': title,
      'description': description,
      'subject': subject.name,
      'inputType': inputType.name,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'answersCount': answersCount,
      'upvotes': upvotes,
      'upvotedBy': upvotedBy,
      'isResolved': isResolved,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
    };
  }

  String get subjectLabel {
    switch (subject) {
      case DoubtSubject.cse:
        return 'CSE';
      case DoubtSubject.physics:
        return 'Physics';
      case DoubtSubject.chemistry:
        return 'Chemistry';
      case DoubtSubject.eee:
        return 'EEE';
      case DoubtSubject.english:
        return 'English';
      case DoubtSubject.mathematics:
        return 'Mathematics';
      case DoubtSubject.other:
        return 'Other';
    }
  }

  Color get subjectColor {
    switch (subject) {
      case DoubtSubject.cse:
        return const Color(0xFF9B30FF);
      case DoubtSubject.physics:
        return const Color(0xFF30AAFF);
      case DoubtSubject.chemistry:
        return const Color(0xFF30FFB0);
      case DoubtSubject.eee:
        return const Color(0xFFFFB030);
      case DoubtSubject.english:
        return const Color(0xFFFF6030);
      case DoubtSubject.mathematics:
        return const Color(0xFFFF30AA);
      case DoubtSubject.other:
        return const Color(0xFF8888AA);
    }
  }
}
extension DoubtSubjectExtension on DoubtSubject {
  String get subjectLabel {
    switch (this) {
      case DoubtSubject.cse:
        return 'CSE';
      case DoubtSubject.physics:
        return 'Physics';
      case DoubtSubject.chemistry:
        return 'Chemistry';
      case DoubtSubject.eee:
        return 'EEE';
      case DoubtSubject.english:
        return 'English';
      case DoubtSubject.mathematics:
        return 'Mathematics';
      case DoubtSubject.other:
        return 'Other';
    }
  }

  Color get subjectColor {
    switch (this) {
      case DoubtSubject.cse:
        return const Color(0xFF9B30FF);
      case DoubtSubject.physics:
        return const Color(0xFF30AAFF);
      case DoubtSubject.chemistry:
        return const Color(0xFF30FFB0);
      case DoubtSubject.eee:
        return const Color(0xFFFFB030);
      case DoubtSubject.english:
        return const Color(0xFFFF6030);
      case DoubtSubject.mathematics:
        return const Color(0xFFFF30AA);
      case DoubtSubject.other:
        return const Color(0xFF8888AA);
    }
  }
}