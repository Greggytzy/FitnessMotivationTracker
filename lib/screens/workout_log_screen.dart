import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';

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
                    title: Text(workout.type),
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
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Workout Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter workout type';
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter duration';
                  }
                  if (int.tryParse(value) == null) {
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  if (int.tryParse(value) == null) {
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
