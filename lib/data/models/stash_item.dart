import 'package:cloud_firestore/cloud_firestore.dart';

class StashItem {
  final String? id;
  final String userId;
  final String content;
  final String type;
  final List<String> tags;
  final Timestamp createdAt;

  StashItem({
    this.id,
    required this.userId,
    required this.content,
    required this.type,
    required this.tags,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'type': type,
      'tags': tags,
      'createdAt': createdAt,
    };
  }
}
