import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String? branch;
  final String? year;
  final String? college;
  final int points;
  final int doubtsPosted;
  final int answersGiven;
  final List<String> badges;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.branch,
    this.year,
    this.college,
    this.points = 0,
    this.doubtsPosted = 0,
    this.answersGiven = 0,
    this.badges = const [],
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      branch: map['branch'],
      year: map['year'],
      college: map['college'],
      points: map['points'] ?? 0,
      doubtsPosted: map['doubtsPosted'] ?? 0,
      answersGiven: map['answersGiven'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'branch': branch,
      'year': year,
      'college': college,
      'points': points,
      'doubtsPosted': doubtsPosted,
      'answersGiven': answersGiven,
      'badges': badges,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? branch,
    String? year,
    String? college,
    int? points,
    int? doubtsPosted,
    int? answersGiven,
    List<String>? badges,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      branch: branch ?? this.branch,
      year: year ?? this.year,
      college: college ?? this.college,
      points: points ?? this.points,
      doubtsPosted: doubtsPosted ?? this.doubtsPosted,
      answersGiven: answersGiven ?? this.answersGiven,
      badges: badges ?? this.badges,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
