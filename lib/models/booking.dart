enum BookingStatus { pending, confirmed, cancelled }

class Booking {
  final String id;
  final String spotId;
  final String spotName;
  final String username;
  final DateTime date;
  final String sessionType;
  final int duration;
  final BookingStatus status;
  final DateTime createdAt;
  final String? instructorName;
  final String? notes;

  Booking({
    required this.id,
    required this.spotId,
    required this.spotName,
    required this.username,
    required this.date,
    required this.sessionType,
    required this.duration,
    required this.status,
    required this.createdAt,
    this.instructorName,
    this.notes,
  });

  Booking copyWith({
    String? id,
    String? spotId,
    String? spotName,
    String? username,
    DateTime? date,
    String? sessionType,
    int? duration,
    BookingStatus? status,
    DateTime? createdAt,
    String? instructorName,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      spotId: spotId ?? this.spotId,
      spotName: spotName ?? this.spotName,
      username: username ?? this.username,
      date: date ?? this.date,
      sessionType: sessionType ?? this.sessionType,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      instructorName: instructorName ?? this.instructorName,
      notes: notes ?? this.notes,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      spotId: json['spotId'],
      spotName: json['spotName'],
      username: json['username'],
      date: DateTime.parse(json['date']),
      sessionType: json['sessionType'],
      duration: json['duration'],
      status: BookingStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      instructorName: json['instructorName'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spotId': spotId,
      'spotName': spotName,
      'username': username,
      'date': date.toIso8601String(),
      'sessionType': sessionType,
      'duration': duration,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'instructorName': instructorName,
      'notes': notes,
    };
  }
}
