import 'package:cloud_firestore/cloud_firestore.dart';

class AnswerModel {
  final String id;
  final String doubtId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final String? imageUrl;
  final int upvotes;
  final List<String> upvotedBy;
  final bool isAccepted;
  final DateTime createdAt;
  final int userPoints;

  AnswerModel({
    required this.id,
    required this.doubtId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    this.imageUrl,
    this.upvotes = 0,
    this.upvotedBy = const [],
    this.isAccepted = false,
    required this.createdAt,
    this.userPoints = 0,
  });

  factory AnswerModel.fromMap(Map<String, dynamic> map, String id) {
    return AnswerModel(
      id: id,
      doubtId: map['doubtId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      upvotes: map['upvotes'] ?? 0,
      upvotedBy: List<String>.from(map['upvotedBy'] ?? []),
      isAccepted: map['isAccepted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userPoints: map['userPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doubtId': doubtId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'imageUrl': imageUrl,
      'upvotes': upvotes,
      'upvotedBy': upvotedBy,
      'isAccepted': isAccepted,
      'createdAt': Timestamp.fromDate(createdAt),
      'userPoints': userPoints,
    };
  }
}
