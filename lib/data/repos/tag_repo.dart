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

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tags')
        .doc(tagId)
        .delete();
  }

  // TODO: Add method for updateTag later
}

@riverpod
TagRepo tagRepo(Ref ref) => TagRepo();

@riverpod
Stream<List<Tag>> tagStream(Ref ref) {
  final tagRepo = ref.watch(tagRepoProvider);
  return tagRepo.getTags();
}
