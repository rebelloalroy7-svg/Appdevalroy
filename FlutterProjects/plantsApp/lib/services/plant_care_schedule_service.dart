import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/plant_care_task.dart';

class PlantCareScheduleService extends ChangeNotifier {
  PlantCareScheduleService() {
    _loadTasks();
  }

  static const _storageKey = 'plant_care_tasks';
  final List<PlantCareTask> _tasks = [];
  SharedPreferences? _prefs;

  List<PlantCareTask> get tasks => List.unmodifiable(_tasks);

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = (jsonDecode(raw) as List<dynamic>)
            .map((item) => PlantCareTask.fromJson(item as Map<String, dynamic>))
            .toList();
        _tasks
          ..clear()
          ..addAll(decoded);
      } catch (e) {
        debugPrint('Failed to decode care tasks: $e');
      }
    }
    notifyListeners();
  }

  Future<void> addTask({
    required String plantName,
    required CareType careType,
    required int frequencyDays,
    String notes = '',
  }) async {
    final task = PlantCareTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      plantName: plantName.trim(),
      careType: careType,
      frequencyDays: frequencyDays,
      notes: notes.trim(),
    );
    _tasks.add(task);
    await _persist();
  }

  Future<void> markCompleted(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(lastCompleted: DateTime.now());
    await _persist();
  }

  Future<void> removeTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final payload = jsonEncode(
      _tasks.map((task) => task.toJson()).toList(growable: false),
    );
    await prefs.setString(_storageKey, payload);
    notifyListeners();
  }
}


