class QuoteModel {
  final String id;
  final String content;
  final String author;
  final List<String> tags;
  final bool isFavorite;
  final DateTime? favoritedAt;

  QuoteModel({
    required this.id,
    required this.content,
    required this.author,
    this.tags = const [],
    this.isFavorite = false,
    this.favoritedAt,
  });

  factory QuoteModel.fromMap(Map<String, dynamic> map, String id) {
    return QuoteModel(
      id: id,
      content: map['content'] ?? '',
      author: map['author'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      isFavorite: map['isFavorite'] ?? false,
      favoritedAt: map['favoritedAt'] != null 
          ? DateTime.parse(map['favoritedAt']) 
          : null,
    );
  }

  factory QuoteModel.fromApi(Map<String, dynamic> map) {
    return QuoteModel(
      id: map['_id'] ?? '',
      content: map['content'] ?? '',
      author: map['author'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'author': author,
      'tags': tags,
      'isFavorite': isFavorite,
      'favoritedAt': favoritedAt?.toIso8601String(),
    };
  }

  QuoteModel copyWith({
    String? id,
    String? content,
    String? author,
    List<String>? tags,
    bool? isFavorite,
    DateTime? favoritedAt,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      content: content ?? this.content,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      favoritedAt: favoritedAt ?? this.favoritedAt,
    );
  }
}
