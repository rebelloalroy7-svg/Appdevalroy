import 'dart:convert';

enum CareType { watering, fertilizing, pruning, misting, custom }

extension CareTypeLabel on CareType {
  String get label {
    switch (this) {
      case CareType.watering:
        return 'Watering';
      case CareType.fertilizing:
        return 'Fertilizing';
      case CareType.pruning:
        return 'Pruning';
      case CareType.misting:
        return 'Misting';
      case CareType.custom:
        return 'Custom Care';
    }
  }

  String get storage => name;

  static CareType fromStorage(String value) {
    return CareType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => CareType.custom,
    );
  }
}

class PlantCareTask {
  const PlantCareTask({
    required this.id,
    required this.plantName,
    required this.careType,
    required this.frequencyDays,
    this.lastCompleted,
    this.notes = '',
  });

  final String id;
  final String plantName;
  final CareType careType;
  final int frequencyDays;
  final DateTime? lastCompleted;
  final String notes;

  bool get isDue {
    if (lastCompleted == null) {
      return true;
    }
    final nextDue = lastCompleted!.add(Duration(days: frequencyDays));
    return DateTime.now().isAfter(nextDue);
  }

  DateTime get nextDue {
    final base = lastCompleted ?? DateTime.now();
    return base.add(Duration(days: frequencyDays));
  }

  PlantCareTask copyWith({
    String? id,
    String? plantName,
    CareType? careType,
    int? frequencyDays,
    DateTime? lastCompleted,
    bool setLastCompletedNull = false,
    String? notes,
  }) {
    return PlantCareTask(
      id: id ?? this.id,
      plantName: plantName ?? this.plantName,
      careType: careType ?? this.careType,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      lastCompleted: setLastCompletedNull
          ? null
          : (lastCompleted ?? this.lastCompleted),
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantName': plantName,
      'careType': careType.storage,
      'frequencyDays': frequencyDays,
      'lastCompleted': lastCompleted?.toIso8601String(),
      'notes': notes,
    };
  }

  factory PlantCareTask.fromJson(Map<String, dynamic> json) {
    return PlantCareTask(
      id: json['id'] as String,
      plantName: json['plantName'] as String,
      careType: CareTypeLabel.fromStorage(json['careType'] as String),
      frequencyDays: (json['frequencyDays'] as num).toInt(),
      lastCompleted: json['lastCompleted'] != null
          ? DateTime.tryParse(json['lastCompleted'] as String)
          : null,
      notes: json['notes'] as String? ?? '',
    );
  }

  static List<PlantCareTask> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => PlantCareTask.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static String encodeList(List<PlantCareTask> tasks) {
    final mapped = tasks.map((task) => task.toJson()).toList();
    return jsonEncode(mapped);
  }
}


