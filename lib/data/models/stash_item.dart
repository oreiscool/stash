import 'package:cloud_firestore/cloud_firestore.dart';

class StashItem {
  final String? id;
  final String userId;
  final String content;
  final String type;
  final List<String> tags;
  final bool isPinned;
  final bool isDeleted;
  final Timestamp? deletedAt;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  StashItem({
    this.id,
    required this.userId,
    required this.content,
    required this.type,
    required this.tags,
    this.isPinned = false,
    this.isDeleted = false,
    this.deletedAt,
    required this.createdAt,
    this.updatedAt,
  });

  StashItem copyWith({
    String? id,
    String? userId,
    String? content,
    String? type,
    List<String>? tags,
    bool? isPinned,
    bool? isDeleted,
    Timestamp? deletedAt,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return StashItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      type: type ?? this.type,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory StashItem.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return StashItem(
      id: documentId,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      type: data['type'] ?? 'Note',
      tags: List<String>.from(data['tags'] ?? []),
      isPinned: data['isPinned'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      deletedAt: data['deletedAt'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'type': type,
      'tags': tags,
      'isPinned': isPinned,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Helper to check if item should be permanently deleted
  bool shouldBeDeleted() {
    if (!isDeleted || deletedAt == null) return false;
    final now = DateTime.now();
    final deletedDate = deletedAt!.toDate();
    final daysSinceDeleted = now.difference(deletedDate).inDays;
    return daysSinceDeleted >= 7;
  }
}
