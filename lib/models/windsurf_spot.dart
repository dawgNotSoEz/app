class WindsurfSpot {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final String difficulty;
  final Map<String, dynamic> conditions;
  final String description;

  WindsurfSpot({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.difficulty,
    required this.conditions,
    required this.description,
  });

  factory WindsurfSpot.fromJson(Map<String, dynamic> json) {
    return WindsurfSpot(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      difficulty: json['difficulty'] as String,
      conditions: json['conditions'] as Map<String, dynamic>,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'rating': rating,
      'difficulty': difficulty,
      'conditions': conditions,
      'description': description,
    };
  }
}
