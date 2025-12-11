class Workout {
  final String id;
  final String type;
  final int duration; // in minutes
  final int calories;
  final DateTime date;

  Workout({
    required this.id,
    required this.type,
    required this.duration,
    required this.calories,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'duration': duration,
      'calories': calories,
      'date': date.toIso8601String(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      type: json['type'],
      duration: json['duration'],
      calories: json['calories'],
      date: DateTime.parse(json['date']),
    );
  }
}
