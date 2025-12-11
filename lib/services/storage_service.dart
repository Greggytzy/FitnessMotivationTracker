import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';
import '../models/goal.dart';
import '../models/quote.dart';

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

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }
}
