class Goal {
  final String id;
  final String description;
  final int targetValue;
  final int currentValue;
  final DateTime createdDate;
  final DateTime? targetDate;

  Goal({
    required this.id,
    required this.description,
    required this.targetValue,
    required this.currentValue,
    required this.createdDate,
    this.targetDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'createdDate': createdDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      description: json['description'],
      targetValue: json['targetValue'],
      currentValue: json['currentValue'],
      createdDate: DateTime.parse(json['createdDate']),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'])
          : null,
    );
  }

  bool get isCompleted => currentValue >= targetValue;
}
