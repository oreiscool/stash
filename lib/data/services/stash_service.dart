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

  // TODO: Add methods for fetching, updating, and deleting stash items
}
