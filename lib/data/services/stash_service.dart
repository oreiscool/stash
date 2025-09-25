import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stash/data/models/stash_item.dart';

class StashServiceException implements Exception {
  final String message;
  StashServiceException(this.message);
  @override
  String toString() => message;
}

class StashService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addStashItem(StashItem item) async {
    try {
      await _db.collection('stashes').add(item.toMap());
    } catch (e) {
      throw StashServiceException('Failed to add item to stash: $e');
    }
  }

  Future<void> updateStashItem(StashItem item) async {
    if (item.id == null) {
      throw StashServiceException('Cannot update an item without an ID.');
    }
    try {
      await _db.collection('stashes').doc(item.id).update(item.toMap());
    } catch (e) {
      throw StashServiceException('Failed to update item in stash: $e');
    }
  }

  Future<void> deleteStashItem(String itemId) async {
    try {
      await _db.collection('stashes').doc(itemId).delete();
    } catch (e) {
      throw StashServiceException('Failed to delete item from stash: $e');
    }
  }
}
