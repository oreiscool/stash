import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/data/services/stash_service.dart';

part 'stash_repo.g.dart';

class StashRepo {
  StashRepo(this._service);
  final StashService _service;

  Future<void> addStashItem({
    required String content,
    required String type,
    List<String> tags = const [],
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw StashServiceException('User not authenticated.');
    }

    final newItem = StashItem(
      userId: userId,
      content: content,
      type: type,
      tags: tags,
      createdAt: Timestamp.now(),
    );

    return _service.addStashItem(newItem);
  }

  Future<void> updateStashItem(StashItem item) async {
    return _service.updateStashItem(item);
  }

  Future<void> deleteStashItem(String itemId) async {
    return _service.deleteStashItem(itemId);
  }
}

@riverpod
Stream<List<StashItem>> stashStream(Ref ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('stash_items')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => StashItem(
                id: doc.id,
                userId: doc['userId'],
                content: doc['content'],
                type: doc['type'],
                tags: List<String>.from(doc['tags']),
                createdAt: doc['createdAt'],
              ),
            )
            .toList(),
      );
}

@riverpod
StashService stashService(Ref ref) => StashService();

@riverpod
StashRepo stashRepo(Ref ref) => StashRepo(ref.watch(stashServiceProvider));

@riverpod
Stream<List<StashItem>> stashSearch(Ref ref, String query) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null || query.isEmpty) {
    return Stream.value([]);
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('stash_items')
      .where('content', isGreaterThanOrEqualTo: query)
      .where('content', isLessThanOrEqualTo: '$query\uf8ff')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => StashItem.fromFirestore(doc.data(), doc.id))
            .toList(),
      );
}
