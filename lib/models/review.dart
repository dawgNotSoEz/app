class Review {
  final String? spotName;
  final int rating; // 1-5
  final String comment;
  final DateTime date;

  Review({
    this.spotName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Review copyWith({
    String? spotName,
    int? rating,
    String? comment,
    DateTime? date,
  }) {
    return Review(
      spotName: spotName ?? this.spotName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
    );
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      spotName: json['spotName'],
      rating: json['rating'] as int,
      comment: json['comment'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spotName': spotName,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }
}
