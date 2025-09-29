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

  StashItem copyWith({
    String? id,
    String? userId,
    String? content,
    String? type,
    List<String>? tags,
    Timestamp? createdAt,
  }) {
    return StashItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
