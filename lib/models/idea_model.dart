class IdeaModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String postedByUid;
  final String postedByName;
  final bool isAnonymous;
  final String? imageBase64;
  final List<String> upvotes;
  final DateTime timestamp;
  final String status;

  IdeaModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.postedByUid,
    required this.postedByName,
    required this.isAnonymous,
    this.imageBase64,
    required this.upvotes,
    required this.timestamp,
    this.status = 'Open',
  });

  factory IdeaModel.fromMap(Map<String, dynamic> map, String documentId) {
    final postedByMap = map['postedBy'] as Map<dynamic, dynamic>?;
    final upvotesList = map['upvotes'] as List<dynamic>?;

    return IdeaModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Others',
      postedByUid: postedByMap?['uid'] ?? '',
      postedByName: postedByMap?['name'] ?? '',
      isAnonymous: map['isAnonymous'] ?? false,
      imageBase64: map['imageBase64'],
      upvotes: upvotesList != null ? List<String>.from(upvotesList) : [],
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      status: map['status'] ?? 'Open',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'postedBy': {
        'uid': postedByUid,
        'name': postedByName,
      },
      'isAnonymous': isAnonymous,
      'imageBase64': imageBase64,
      'upvotes': upvotes,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  IdeaModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? postedByUid,
    String? postedByName,
    bool? isAnonymous,
    String? imageBase64,
    List<String>? upvotes,
    DateTime? timestamp,
    String? status,
  }) {
    return IdeaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      postedByUid: postedByUid ?? this.postedByUid,
      postedByName: postedByName ?? this.postedByName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      imageBase64: imageBase64 ?? this.imageBase64,
      upvotes: upvotes ?? this.upvotes,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
