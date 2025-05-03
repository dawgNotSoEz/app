class Review {
  final String id;
  final String spotId;
  final String username;
  final String? spotName;
  final double rating; // 1-5
  final String comment;
  final DateTime date;
  final String? userPhotoUrl;

  Review({
    required this.id,
    required this.spotId,
    required this.username,
    this.spotName,
    required this.rating,
    required this.comment,
    required this.date,
    this.userPhotoUrl,
  });

  Review copyWith({
    String? id,
    String? spotId,
    String? username,
    String? spotName,
    double? rating,
    String? comment,
    DateTime? date,
    String? userPhotoUrl,
  }) {
    return Review(
      id: id ?? this.id,
      spotId: spotId ?? this.spotId,
      username: username ?? this.username,
      spotName: spotName ?? this.spotName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
    );
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      spotId: json['spotId'],
      username: json['username'],
      spotName: json['spotName'],
      rating: json['rating'] is int ? (json['rating'] as int).toDouble() : json['rating'],
      comment: json['comment'],
      date: DateTime.parse(json['date']),
      userPhotoUrl: json['userPhotoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spotId': spotId,
      'username': username,
      'spotName': spotName,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
      'userPhotoUrl': userPhotoUrl,
    };
  }
}
