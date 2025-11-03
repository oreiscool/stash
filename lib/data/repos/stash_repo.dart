import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:stash/data/services/stash_service.dart';
import 'package:stash/providers/ui_providers.dart';
import 'package:stash/providers/sort_providers.dart';

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

List<StashItem> _sortItems(List<StashItem> items, SortMode sortMode) {
  // Sort: pinned items first (by updatedAt), then unpinned items (by updatedAt)
  final pinned = items.where((item) => item.isPinned).toList();
  final unpinned = items.where((item) => !item.isPinned).toList();

  // Sort based on mode
  void sortByMode(List<StashItem> list) {
    list.sort((a, b) {
      final aTime = a.updatedAt ?? a.createdAt;
      final bTime = b.updatedAt ?? b.createdAt;

      switch (sortMode) {
        case SortMode.recent:
          return bTime.compareTo(aTime); // Newest first
        case SortMode.oldest:
          return aTime.compareTo(bTime); // Oldest first
      }
    });
  }

  sortByMode(pinned);
  sortByMode(unpinned);

  return [...pinned, ...unpinned];
}

@riverpod
Stream<List<StashItem>> stashStream(Ref ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  final selectedTags = ref.watch(selectedTagsProvider);
  final sortModeAsync = ref.watch(sortPreferenceProvider);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('stash_items')
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) {
        final sortMode = sortModeAsync.maybeWhen(
          data: (mode) => mode,
          orElse: () => SortMode.recent,
        );

        final selectedTagsSet = selectedTags.toSet();
        final items = snapshot.docs
            .map((doc) => StashItem.fromFirestore(doc.data(), doc.id))
            .where((item) => !item.isDeleted)
            .where(
              (item) =>
                  selectedTags.isEmpty ||
                  item.tags.any((tag) => selectedTagsSet.contains(tag)),
            )
            .toList();

        return _sortItems(items, sortMode);
      });
}

@riverpod
Stream<List<StashItem>> trashStream(Ref ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  final sortModeAsync = ref.watch(sortPreferenceProvider);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('stash_items')
      .where('isDeleted', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        final sortMode = sortModeAsync.maybeWhen(
          data: (mode) => mode,
          orElse: () => SortMode.recent,
        );

        final items = snapshot.docs
            .map((doc) => StashItem.fromFirestore(doc.data(), doc.id))
            .toList();

        return _sortItems(items, sortMode);
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

  final sortModeAsync = ref.watch(sortPreferenceProvider);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('stash_items')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        final sortMode = sortModeAsync.maybeWhen(
          data: (mode) => mode,
          orElse: () => SortMode.recent,
        );

        final items = snapshot.docs
            .map((doc) => StashItem.fromFirestore(doc.data(), doc.id))
            .where((item) => !item.isDeleted)
            .where((item) {
              final contentMatch = item.content.toLowerCase().contains(
                normalizedQuery,
              );
              final tagsMatch = item.tags.any(
                (tag) => tag.toLowerCase().contains(normalizedQuery),
              );
              return contentMatch || tagsMatch;
            })
            .toList();

        return _sortItems(items, sortMode);
      });
}
