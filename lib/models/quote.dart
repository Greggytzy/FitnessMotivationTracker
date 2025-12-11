class Quote {
  final String id;
  final String text;
  final String author;
  final bool isFavorite;
  final DateTime dateAdded;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    this.isFavorite = false,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'isFavorite': isFavorite,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      text: json['text'],
      author: json['author'],
      isFavorite: json['isFavorite'] ?? false,
      dateAdded: DateTime.parse(json['dateAdded']),
    );
  }
}
