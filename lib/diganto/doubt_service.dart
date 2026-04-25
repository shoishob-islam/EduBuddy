import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'doubt_model.dart';
import 'answer_model.dart';

class DoubtService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  // Post a doubt
  Future<String?> postDoubt({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String title,
    required String description,
    required DoubtSubject subject,
    DoubtInputType inputType = DoubtInputType.text,
    File? imageFile,
    File? audioFile,
    List<String> tags = const [],
  }) async {
    try {
      String? imageUrl;
      String? audioUrl;

      if (imageFile != null) {
        final ref = _storage
            .ref()
            .child('doubts')
            .child(userId)
            .child('${_uuid.v4()}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      if (audioFile != null) {
        final ref = _storage
            .ref()
            .child('doubts')
            .child(userId)
            .child('${_uuid.v4()}.m4a');
        await ref.putFile(audioFile);
        audioUrl = await ref.getDownloadURL();
      }

      final doubtId = _uuid.v4();
      final doubt = DoubtModel(
        id: doubtId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        title: title,
        description: description,
        subject: subject,
        inputType: inputType,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        createdAt: DateTime.now(),
        tags: tags,
      );

      await _firestore.collection('doubts').doc(doubtId).set(doubt.toMap());

      await _firestore.collection('users').doc(userId).update({
        'doubtsPosted': FieldValue.increment(1),
      });

      return doubtId;
    } catch (e) {
      print('Error posting doubt: $e');
      return null;
    }
  }

  // Get all doubts
  Stream<List<DoubtModel>> getDoubts({
    DoubtSubject? subject,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection('doubts')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (subject != null) {
      query = query.where('subject', isEqualTo: subject.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return DoubtModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // Get doubt by ID
  Future<DoubtModel?> getDoubtById(String doubtId) async {
    final doc = await _firestore.collection('doubts').doc(doubtId).get();
    if (doc.exists) {
      return DoubtModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Get answers for a doubt
  Stream<List<AnswerModel>> getAnswers(String doubtId) {
    return _firestore
        .collection('doubts')
        .doc(doubtId)
        .collection('answers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AnswerModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // Post an answer
  Future<bool> postAnswer({
    required String doubtId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String content,
    File? imageFile,
    int userPoints = 0,
  }) async {
    try {
      String? imageUrl;

      if (imageFile != null) {
        final ref = _storage
            .ref()
            .child('answers')
            .child(userId)
            .child('${_uuid.v4()}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final answerId = _uuid.v4();
      final answer = AnswerModel(
        id: answerId,
        doubtId: doubtId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        content: content,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        userPoints: userPoints,
      );

      await _firestore
          .collection('doubts')
          .doc(doubtId)
          .collection('answers')
          .doc(answerId)
          .set(answer.toMap());

      await _firestore.collection('doubts').doc(doubtId).update({
        'answersCount': FieldValue.increment(1),
      });

      await _firestore.collection('users').doc(userId).update({
        'answersGiven': FieldValue.increment(1),
        'points': FieldValue.increment(10),
      });

      return true;
    } catch (e) {
      print('Error posting answer: $e');
      return false;
    }
  }

  // Upvote a doubt
  Future<void> upvoteDoubt(String doubtId, String userId) async {
    final ref = _firestore.collection('doubts').doc(doubtId);
    final doc = await ref.get();

    if (doc.exists) {
      final List<String> upvotedBy =
          List<String>.from(doc.data()?['upvotedBy'] ?? []);

      if (upvotedBy.contains(userId)) {
        await ref.update({
          'upvotes': FieldValue.increment(-1),
          'upvotedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        await ref.update({
          'upvotes': FieldValue.increment(1),
          'upvotedBy': FieldValue.arrayUnion([userId]),
        });
      }
    }
  }

  // Upvote an answer
  Future<void> upvoteAnswer(
      String doubtId, String answerId, String userId) async {
    final ref = _firestore
        .collection('doubts')
        .doc(doubtId)
        .collection('answers')
        .doc(answerId);
    final doc = await ref.get();

    if (doc.exists) {
      final List<String> upvotedBy =
          List<String>.from(doc.data()?['upvotedBy'] ?? []);

      if (upvotedBy.contains(userId)) {
        await ref.update({
          'upvotes': FieldValue.increment(-1),
          'upvotedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        await ref.update({
          'upvotes': FieldValue.increment(1),
          'upvotedBy': FieldValue.arrayUnion([userId]),
        });
      }
    }
  }

  // Accept answer
  Future<void> acceptAnswer(String doubtId, String answerId) async {
    final batch = _firestore.batch();

    batch.update(
      _firestore
          .collection('doubts')
          .doc(doubtId)
          .collection('answers')
          .doc(answerId),
      {'isAccepted': true},
    );

    batch.update(
      _firestore.collection('doubts').doc(doubtId),
      {'isResolved': true},
    );

    await batch.commit();
  }

  // Get user doubts
  Stream<List<DoubtModel>> getUserDoubts(String userId) {
    return _firestore
        .collection('doubts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return DoubtModel.fromMap(
          doc.data(),
          doc.id,
        );
      }).toList();
    });
  }

  // Search doubts
  Future<List<DoubtModel>> searchDoubts(String query) async {
    final results = await _firestore
        .collection('doubts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return results.docs
        .map((doc) => DoubtModel.fromMap(doc.data(), doc.id))
        .where((doubt) =>
            doubt.title.toLowerCase().contains(query.toLowerCase()) ||
            doubt.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}