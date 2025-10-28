import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stash/data/models/stash_item.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StashServiceException implements Exception {
  final String message;
  StashServiceException(this.message);
  @override
  String toString() => message;
}

class StashService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addStashItem(StashItem item) async {
    try {
      await _db
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('stash_items')
          .add(item.toMap());
    } catch (e) {
      throw StashServiceException('Failed to add item to stash: $e');
    }
  }

  Future<void> updateStashItem(
    StashItem item, {
    bool updateTimeStamp = true,
  }) async {
    if (item.id == null) {
      throw StashServiceException('Cannot update an item without an ID.');
    }
    try {
      final updateData = item.toMap();

      // Only update timestamp if explicitly requested
      if (updateTimeStamp) {
        updateData['updatedAt'] = FieldValue.serverTimestamp();
      }

      await _db
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('stash_items')
          .doc(item.id)
          .update(updateData);
    } catch (e) {
      throw StashServiceException('Failed to update item in stash: $e');
    }
  }

  Future<void> softDeleteStashItem(String itemId) async {
    try {
      await _db
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('stash_items')
          .doc(itemId)
          .update({
            'isDeleted': true,
            'deletedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw StashServiceException('Failed to delete item: $e');
    }
  }

  Future<void> restoreStashItem(String itemId) async {
    try {
      await _db
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('stash_items')
          .doc(itemId)
          .update({'isDeleted': false, 'deletedAt': null});
    } catch (e) {
      throw StashServiceException('Failed to restore item: $e');
    }
  }

  Future<void> permanentlyDeleteStashItem(String itemId) async {
    try {
      await _db
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('stash_items')
          .doc(itemId)
          .delete();
    } catch (e) {
      throw StashServiceException('Failed to permanently delete item: $e');
    }
  }

  Future<void> cleanupOldDeletedItems() async {
    try {
      final sevenDaysAgo = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: 7)),
      );

      final snapshot = await _db
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('stash_items')
          .where('isDeleted', isEqualTo: true)
          .where('deletedAt', isLessThan: sevenDaysAgo)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw StashServiceException('Failed to cleanup old items: $e');
    }
  }
}
