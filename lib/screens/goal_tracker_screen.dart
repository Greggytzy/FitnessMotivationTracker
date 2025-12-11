import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';

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
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0
                                ? Colors.green
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).round()}% complete',
                          style: TextStyle(
                            color: progress >= 1.0
                                ? Colors.green
                                : Colors.grey[600],
                            fontWeight: progress >= 1.0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (goal.targetDate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Target: ${goal.targetDate!.toString().split(' ')[0]}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                    return 'Please enter goal description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _targetValueController,
                decoration: const InputDecoration(labelText: 'Target Value'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter target value';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _currentValueController,
                decoration: const InputDecoration(labelText: 'Current Value'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current value';
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
