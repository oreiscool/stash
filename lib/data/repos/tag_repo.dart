import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stash/data/models/tag.dart';

part 'tag_repo.g.dart';

class TagRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Tag>> getTags() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Tag.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addTag(String tagName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated.');
    }

    final newTag = {'name': tagName.trim()};

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .add(newTag);
  }

  Future<void> deleteTag(String tagId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated.');
    }

    // Get the tag name first to remove it from all items
    final tagDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .doc(tagId)
        .get();

    final tagName = (tagDoc.data()?['name'] as String?) ?? '';

    // Remove the tag from all stash items that reference it
    if (tagName.isNotEmpty) {
      final itemsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('stash_items')
          .where('tags', arrayContains: tagName)
          .get();

      // Update all items to remove this tag
      for (final itemDoc in itemsSnapshot.docs) {
        final currentTags = List<String>.from(
          itemDoc.data()['tags'] as List? ?? [],
        );
        currentTags.remove(tagName);

        await itemDoc.reference.update({'tags': currentTags});
      }
    }

    // Delete the tag
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .doc(tagId)
        .delete();
  }

  Future<void> updateTag(String tagId, String newName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated.');
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .doc(tagId)
        .update({'name': newName.trim()});
  }
}

@riverpod
TagRepo tagRepo(Ref ref) => TagRepo();

@riverpod
Stream<List<Tag>> tagStream(Ref ref) {
  final tagRepo = ref.watch(tagRepoProvider);
  return tagRepo.getTags();
}
