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

  // TODO: Add methods for updating and deleting items.
}

@riverpod
Stream<List<StashItem>> stashStream(Ref ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('stashes')
      .where('userId', isEqualTo: userId)
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
