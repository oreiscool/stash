import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/data/services/stash_service.dart';
import 'package:stash/providers/ui_providers.dart';

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
      isPinned: false,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    return _service.addStashItem(newItem);
  }

  Future<void> updateStashItem(
    StashItem item, {
    bool updateTimeStamp = true,
  }) async {
    return _service.updateStashItem(item, updateTimeStamp: updateTimeStamp);
  }

  Future<void> moveToTrash(String itemId) async {
    return _service.softDeleteStashItem(itemId);
  }

  Future<void> restoreFromTrash(String itemId) async {
    return _service.restoreStashItem(itemId);
  }

  Future<void> permanentlyDelete(String itemId) async {
    return _service.permanentlyDeleteStashItem(itemId);
  }

  Future<void> cleanupOldDeletedItems() async {
    return _service.cleanupOldDeletedItems();
  }

  Future<void> togglePin(StashItem item) async {
    if (item.id == null) {
      throw StashServiceException('Cannot pin/unpin an item without an ID.');
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw StashServiceException('User not authenticated.');
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('stash_items')
        .doc(item.id)
        .update({'isPinned': !item.isPinned});
  }
}

List<StashItem> _sortItems(List<StashItem> items) {
  // Sort: pinned items first (by updatedAt), then unpinned items (by updatedAt)
  final pinned = items.where((item) => item.isPinned).toList();
  final unpinned = items.where((item) => !item.isPinned).toList();

  pinned.sort((a, b) {
    final aTime = a.updatedAt ?? a.createdAt;
    final bTime = b.updatedAt ?? b.createdAt;
    return bTime.compareTo(aTime);
  });

  unpinned.sort((a, b) {
    final aTime = a.updatedAt ?? a.createdAt;
    final bTime = b.updatedAt ?? b.createdAt;
    return bTime.compareTo(aTime);
  });
  return [...pinned, ...unpinned];
}

@riverpod
Stream<List<StashItem>> stashStream(Ref ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  final selectedTags = ref.watch(selectedTagsProvider);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('stash_items')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) {
        var items = snapshot.docs
            .map((doc) => StashItem.fromFirestore(doc.data(), doc.id))
            .toList();
        items = items.where((item) => !item.isDeleted).toList();
        if (selectedTags.isNotEmpty) {
          items = items
              .where(
                (item) => item.tags.any((tag) => selectedTags.contains(tag)),
              )
              .toList();
        }
        return _sortItems(items);
      });
}

@riverpod
Stream<List<StashItem>> trashStream(Ref ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('stash_items')
      .where('isDeleted', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        var items = snapshot.docs
            .map((doc) => StashItem.fromFirestore(doc.data(), doc.id))
            .toList();

        // Sort by deletion date (most recent first)
        items.sort((a, b) {
          final aTime = a.deletedAt ?? Timestamp.now();
          final bTime = b.deletedAt ?? Timestamp.now();
          return bTime.compareTo(aTime);
        });
        return items;
      });
}

@riverpod
StashService stashService(Ref ref) => StashService();

@riverpod
StashRepo stashRepo(Ref ref) => StashRepo(ref.watch(stashServiceProvider));

@riverpod
Stream<List<StashItem>> stashSearch(Ref ref, String query) {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  final normalizedQuery = query.trim().toLowerCase();

  if (userId == null || normalizedQuery.isEmpty) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('stash_items')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        var items = snapshot.docs
            .map((doc) => StashItem.fromFirestore(doc.data(), doc.id))
            .toList();
        items = items.where((item) => !item.isDeleted).toList();
        items = items.where((item) {
          final content = item.content.toLowerCase();
          final type = item.type.toLowerCase();
          final tags = item.tags.map((tag) => tag.toLowerCase()).toList();

          return content.contains(normalizedQuery) ||
              type.contains(normalizedQuery) ||
              tags.any((tag) => tag.contains(normalizedQuery));
        }).toList();

        return _sortItems(items);
      });
}
