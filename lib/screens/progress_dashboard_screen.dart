import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';

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
              child: Text('No workout data available. Start logging workouts!'),
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
                  if (_filteredWorkouts.isNotEmpty) ...[
                    const Text(
                      'Workout Types Distribution',
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

class WorkoutData {
  final String type;
  final int count;

  WorkoutData(this.type, this.count);
}
