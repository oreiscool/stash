class Tag {
  final String id;
  final String name;

  Tag({required this.id, required this.name});

  factory Tag.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Tag(id: documentId, name: data['name'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}
