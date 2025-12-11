import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

// =========================================================================
// 1. DATA MODELS (Workout, Goal, Quote)
// =========================================================================

// --- workout.dart ---
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

// --- goal.dart ---
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

// --- quote.dart ---
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

// =========================================================================
// 2. STORAGE SERVICE (StorageService)
// =========================================================================

// --- storage_service.dart ---
class StorageService {
  static const String _workoutsKey = 'workouts';
  static const String _goalsKey = 'goals';
  static const String _quotesKey = 'quotes';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // Workouts
  static Future<List<Workout>> getWorkouts() async {
    final prefs = await _prefs;
    final workoutsJson = prefs.getStringList(_workoutsKey) ?? [];
    return workoutsJson
        .map((json) => Workout.fromJson(jsonDecode(json)))
        .toList();
  }

  static Future<void> saveWorkouts(List<Workout> workouts) async {
    final prefs = await _prefs;
    final workoutsJson = workouts
        .map((workout) => jsonEncode(workout.toJson()))
        .toList();
    await prefs.setStringList(_workoutsKey, workoutsJson);
  }

  static Future<void> addWorkout(Workout workout) async {
    final workouts = await getWorkouts();
    workouts.add(workout);
    await saveWorkouts(workouts);
  }

  static Future<void> updateWorkout(Workout updatedWorkout) async {
    final workouts = await getWorkouts();
    final index = workouts.indexWhere((w) => w.id == updatedWorkout.id);
    if (index != -1) {
      workouts[index] = updatedWorkout;
      await saveWorkouts(workouts);
    }
  }

  static Future<void> deleteWorkout(String workoutId) async {
    final workouts = await getWorkouts();
    workouts.removeWhere((w) => w.id == workoutId);
    await saveWorkouts(workouts);
  }

  // Goals
  static Future<List<Goal>> getGoals() async {
    final prefs = await _prefs;
    final goalsJson = prefs.getStringList(_goalsKey) ?? [];
    return goalsJson.map((json) => Goal.fromJson(jsonDecode(json))).toList();
  }

  static Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await _prefs;
    final goalsJson = goals.map((goal) => jsonEncode(goal.toJson())).toList();
    await prefs.setStringList(_goalsKey, goalsJson);
  }

  static Future<void> addGoal(Goal goal) async {
    final goals = await getGoals();
    goals.add(goal);
    await saveGoals(goals);
  }

  static Future<void> updateGoal(Goal updatedGoal) async {
    final goals = await getGoals();
    final index = goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      goals[index] = updatedGoal;
      await saveGoals(goals);
    }
  }

  static Future<void> deleteGoal(String goalId) async {
    final goals = await getGoals();
    goals.removeWhere((g) => g.id == goalId);
    await saveGoals(goals);
  }

  // Quotes
  static Future<List<Quote>> getQuotes() async {
    final prefs = await _prefs;
    final quotesJson = prefs.getStringList(_quotesKey) ?? [];
    return quotesJson.map((json) => Quote.fromJson(jsonDecode(json))).toList();
  }

  static Future<void> saveQuotes(List<Quote> quotes) async {
    final prefs = await _prefs;
    final quotesJson = quotes
        .map((quote) => jsonEncode(quote.toJson()))
        .toList();
    await prefs.setStringList(_quotesKey, quotesJson);
  }

  static Future<void> addQuote(Quote quote) async {
    final quotes = await getQuotes();
    quotes.add(quote);
    await saveQuotes(quotes);
  }

  static Future<void> updateQuote(Quote updatedQuote) async {
    final quotes = await getQuotes();
    final index = quotes.indexWhere((q) => q.id == updatedQuote.id);
    if (index != -1) {
      quotes[index] = updatedQuote;
      await saveQuotes(quotes);
    }
  }

  // Settings
  static Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  // Clear All Data (Added for Settings Screen functionality)
  static Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.remove(_workoutsKey);
    await prefs.remove(_goalsKey);
    await prefs.remove(_quotesKey);
    // Note: Leaving _notificationsEnabledKey as is, as it's a setting
  }
}

// =========================================================================
// 3. SCREENS AND DIALOGS
// =========================================================================

// --- home_screen.dart ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Motivation Tracker')),
      body: const Center(child: Text('Welcome to Fitness Motivation Tracker!')),
    );
  }
}

// --- workout_log_screen.dart / AddWorkoutDialog ---
class AddWorkoutDialog extends StatefulWidget {
  final Workout? workout;
  const AddWorkoutDialog({super.key, this.workout});

  @override
  State<AddWorkoutDialog> createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends State<AddWorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.workout != null) {
      _typeController.text = widget.workout!.type;
      _durationController.text = widget.workout!.duration.toString();
      _caloriesController.text = widget.workout!.calories.toString();
      _selectedDate = widget.workout!.date;
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.workout == null ? 'Add Workout' : 'Edit Workout'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Workout Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a workout type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Calories Burned'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Date: ${_selectedDate.toString().split(' ')[0]}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final workout = Workout(
                id:
                    widget.workout?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                type: _typeController.text,
                duration: int.parse(_durationController.text),
                date: _selectedDate,
                calories: int.parse(_caloriesController.text),
              );
              Navigator.of(context).pop(workout);
            }
          },
          child: Text(widget.workout == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  List<Workout> _workouts = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workouts = await StorageService.getWorkouts();
    setState(() {
      _workouts = workouts..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _addWorkout() async {
    final result = await showDialog<Workout>(
      context: context,
      builder: (context) => const AddWorkoutDialog(),
    );

    if (result != null) {
      await StorageService.addWorkout(result);
      await _loadWorkouts();
    }
  }

  Future<void> _editWorkout(Workout workout) async {
    final result = await showDialog<Workout>(
      context: context,
      builder: (context) => AddWorkoutDialog(workout: workout),
    );

    if (result != null) {
      await StorageService.updateWorkout(result);
      await _loadWorkouts();
    }
  }

  Future<void> _deleteWorkout(String workoutId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteWorkout(workoutId);
      await _loadWorkouts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Log')),
      body: _workouts.isEmpty
          ? const Center(
              child: Text('No workouts yet. Add your first workout!'),
            )
          : ListView.builder(
              itemCount: _workouts.length,
              itemBuilder: (context, index) {
                final workout = _workouts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      workout.type,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${workout.duration} min • ${workout.calories} cal • ${workout.date.toString().split(' ')[0]}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editWorkout(workout);
                        } else if (value == 'delete') {
                          _deleteWorkout(workout.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addWorkout,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- goal_tracker_screen.dart / AddGoalDialog ---
class AddGoalDialog extends StatefulWidget {
  final Goal? goal;
  const AddGoalDialog({super.key, this.goal});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _currentValueController = TextEditingController();
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _descriptionController.text = widget.goal!.description;
      _targetValueController.text = widget.goal!.targetValue.toString();
      _currentValueController.text = widget.goal!.currentValue.toString();
      _targetDate = widget.goal!.targetDate;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _targetValueController.dispose();
    _currentValueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goal == null ? 'Add Goal' : 'Edit Goal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Goal Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _targetValueController,
                decoration: const InputDecoration(
                  labelText: 'Target Value (e.g., 10)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _currentValueController,
                decoration: const InputDecoration(
                  labelText: 'Current Value (e.g., 0)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    _targetDate == null
                        ? 'No target date'
                        : 'Target: ${_targetDate!.toString().split(' ')[0]}',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Set Date'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final goal = Goal(
                id:
                    widget.goal?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                description: _descriptionController.text,
                targetValue: int.parse(_targetValueController.text),
                currentValue: int.parse(_currentValueController.text),
                createdDate: widget.goal?.createdDate ?? DateTime.now(),
                targetDate: _targetDate,
              );
              Navigator.of(context).pop(goal);
            }
          },
          child: Text(widget.goal == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}

class GoalTrackerScreen extends StatefulWidget {
  const GoalTrackerScreen({super.key});

  @override
  State<GoalTrackerScreen> createState() => _GoalTrackerScreenState();
}

class _GoalTrackerScreenState extends State<GoalTrackerScreen> {
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await StorageService.getGoals();
    setState(() {
      _goals = goals;
    });
  }

  Future<void> _addGoal() async {
    final result = await showDialog<Goal>(
      context: context,
      builder: (context) => const AddGoalDialog(),
    );

    if (result != null) {
      await StorageService.addGoal(result);
      await _loadGoals();
    }
  }

  Future<void> _editGoal(Goal goal) async {
    final result = await showDialog<Goal>(
      context: context,
      builder: (context) => AddGoalDialog(goal: goal),
    );

    if (result != null) {
      await StorageService.updateGoal(result);
      await _loadGoals();
    }
  }

  Future<void> _deleteGoal(String goalId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteGoal(goalId);
      await _loadGoals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goal Tracker')),
      body: _goals.isEmpty
          ? const Center(child: Text('No goals yet. Add your first goal!'))
          : ListView.builder(
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final progress = goal.currentValue / goal.targetValue;
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                goal.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editGoal(goal);
                                } else if (value == 'delete') {
                                  _deleteGoal(goal.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${goal.currentValue} / ${goal.targetValue}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            goal.isCompleted
                                ? Colors.green
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${(progress * 100).round()}% complete',
                              style: TextStyle(
                                color: goal.isCompleted
                                    ? Colors.green
                                    : Colors.grey[600],
                                fontWeight: goal.isCompleted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (goal.targetDate != null)
                              Text(
                                'Target: ${goal.targetDate!.toString().split(' ')[0]}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGoal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- progress_dashboard_screen.dart ---
class WorkoutData {
  final String type;
  final int count;

  WorkoutData(this.type, this.count);
}

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  List<Workout> _workouts = [];
  String _filter = 'all'; // 'all', 'week', 'month'

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workouts = await StorageService.getWorkouts();
    setState(() {
      _workouts = workouts;
    });
  }

  List<Workout> get _filteredWorkouts {
    final now = DateTime.now();
    switch (_filter) {
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return _workouts.where((w) => w.date.isAfter(weekAgo)).toList();
      case 'month':
        final monthAgo = now.subtract(const Duration(days: 30));
        return _workouts.where((w) => w.date.isAfter(monthAgo)).toList();
      default:
        return _workouts;
    }
  }

  int get _totalWorkouts => _filteredWorkouts.length;

  int get _totalCalories =>
      _filteredWorkouts.fold(0, (sum, w) => sum + w.calories);

  int get _totalDuration =>
      _filteredWorkouts.fold(0, (sum, w) => sum + w.duration);

  List<String> get _chartLabels {
    final workoutTypes = _filteredWorkouts.map((w) => w.type).toSet();
    return workoutTypes.toList();
  }

  List<BarChartGroupData> _createChartData() {
    final workoutTypes = _chartLabels;
    final barGroups = <BarChartGroupData>[];

    for (int i = 0; i < workoutTypes.length; i++) {
      final type = workoutTypes[i];
      final count = _filteredWorkouts.where((w) => w.type == type).length;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.blue,
              width: 20,
            ),
          ],
        ),
      );
    }
    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Dashboard')),
      body: _workouts.isEmpty
          ? const Center(
              child: Text(
                'Log some workouts to see your progress dashboard!',
                textAlign: TextAlign.center,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Buttons
                  const Text(
                    'Time Period',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('All Time'),
                        selected: _filter == 'all',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _filter = 'all');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('This Week'),
                        selected: _filter == 'week',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _filter = 'week');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('This Month'),
                        selected: _filter == 'month',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _filter = 'month');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  _totalWorkouts.toString(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text('Total Workouts'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  '${_totalCalories}cal',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Text('Total Calories'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '${_totalDuration}min',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const Text('Total Duration'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chart
                  if (_chartLabels.isNotEmpty) ...[
                    const Text(
                      'Workout Types Distribution (Count)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          barGroups: _createChartData(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < _chartLabels.length) {
                                    return Text(
                                      _chartLabels[value.toInt()],
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

// --- motivational_reminders_screen.dart / AddQuoteDialog ---
class AddQuoteDialog extends StatefulWidget {
  const AddQuoteDialog({super.key});

  @override
  State<AddQuoteDialog> createState() => _AddQuoteDialogState();
}

class _AddQuoteDialogState extends State<AddQuoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _authorController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Motivational Quote'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(labelText: 'Quote Text'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quote text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter author name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final quote = Quote(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                text: _textController.text,
                author: _authorController.text,
                dateAdded: DateTime.now(),
              );
              Navigator.of(context).pop(quote);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class MotivationalRemindersScreen extends StatefulWidget {
  const MotivationalRemindersScreen({super.key});

  @override
  State<MotivationalRemindersScreen> createState() =>
      _MotivationalRemindersScreenState();
}

class _MotivationalRemindersScreenState
    extends State<MotivationalRemindersScreen>
    with SingleTickerProviderStateMixin {
  List<Quote> _quotes = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadQuotes();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    final quotes = await StorageService.getQuotes();
    setState(() {
      _quotes = quotes;
    });
  }

  Future<void> _addQuote() async {
    final result = await showDialog<Quote>(
      context: context,
      builder: (context) => const AddQuoteDialog(),
    );

    if (result != null) {
      await StorageService.addQuote(result);
      await _loadQuotes();
    }
  }

  Future<void> _toggleFavorite(Quote quote) async {
    final updatedQuote = Quote(
      id: quote.id,
      text: quote.text,
      author: quote.author,
      isFavorite: !quote.isFavorite,
      dateAdded: quote.dateAdded,
    );
    await StorageService.updateQuote(updatedQuote);
    await _loadQuotes();
  }

  Quote? get _dailyQuote {
    if (_quotes.isEmpty) return null;
    return _quotes[_random.nextInt(_quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    final dailyQuote = _dailyQuote;
    final favoriteQuotes = _quotes.where((q) => q.isFavorite).toList();
    final allQuotesSorted = _quotes.toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    return Scaffold(
      appBar: AppBar(title: const Text('Motivational Reminders')),
      body: _quotes.isEmpty
          ? const Center(
              child: Text('No quotes yet. Add your first motivational quote!'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Quote
                  if (dailyQuote != null) ...[
                    const Text(
                      'Quote of the Day',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Text(
                                dailyQuote.text,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '- ${dailyQuote.author}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _toggleFavorite(dailyQuote),
                                    icon: Icon(
                                      dailyQuote.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: dailyQuote.isFavorite
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Favorite Quotes
                  if (favoriteQuotes.isNotEmpty) ...[
                    const Text(
                      'Favorite Quotes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: favoriteQuotes.length,
                      itemBuilder: (context, index) {
                        final quote = favoriteQuotes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(quote.text),
                            subtitle: Text('- ${quote.author}'),
                            trailing: IconButton(
                              onPressed: () => _toggleFavorite(quote),
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],

                  // All Quotes
                  const Text(
                    'All Quotes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allQuotesSorted.length,
                    itemBuilder: (context, index) {
                      final quote = allQuotesSorted[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(quote.text),
                          subtitle: Text('- ${quote.author}'),
                          trailing: IconButton(
                            onPressed: () => _toggleFavorite(quote),
                            icon: Icon(
                              quote.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: quote.isFavorite
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuote,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- settings_screen.dart ---
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notificationsEnabled = await StorageService.getNotificationsEnabled();
    setState(() {
      _notificationsEnabled = notificationsEnabled;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    await StorageService.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _showClearDataDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your workouts, goals, and quotes. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.clearAllData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data has been cleared!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // Notifications Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Daily Reminders'),
            subtitle: Text(
              kIsWeb
                  ? 'Notifications not available on web'
                  : 'Receive motivational reminders',
            ),
            value: _notificationsEnabled,
            onChanged: kIsWeb ? null : _toggleNotifications,
          ),
          const Divider(),

          // About Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
            trailing: Icon(Icons.info_outline),
          ),
          const Divider(),

          // Data Management
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Data Management',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            title: const Text('Clear All Data'),
            subtitle: const Text('Remove all workouts, goals, and quotes'),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () => _showClearDataDialog(),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 4. MAIN APPLICATION STRUCTURE (main.dart original)
// =========================================================================

void main() {
  // WidgetsFlutterBinding.ensureInitialized(); // Recommended if using async main()
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Motivation Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xFF7C4DFF), // Anime-inspired Purple
        colorScheme: const ColorScheme(
          primary: Color(0xFF7C4DFF), // Purple
          secondary: Color(0xFFFF4081), // Vibrant Pink
          surface: Color(0xFF1A1A2E), // Dark blue-gray
          background: Color(0xFF16213E), // Dark blue
          error: Color(0xFFFF6B6B), // Coral red
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF16213E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A2E),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C4DFF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            elevation: 4,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    WorkoutLogScreen(),
    GoalTrackerScreen(),
    ProgressDashboardScreen(),
    MotivationalRemindersScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workout Log',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7C4DFF),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
