import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/widgets/custom_button.dart';
import 'package:habit_tracker/widgets/custom_text_field.dart';

class EditHabitScreen extends StatefulWidget {
  final HabitModel habit;

  const EditHabitScreen({
    super.key,
    required this.habit,
  });

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  
  late HabitCategory _selectedCategory;
  late HabitFrequency _selectedFrequency;
  DateTime? _selectedStartDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _notesController = TextEditingController(text: widget.habit.notes ?? '');
    _selectedCategory = widget.habit.category;
    _selectedFrequency = widget.habit.frequency;
    _selectedStartDate = widget.habit.startDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _updateHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final success = await habitProvider.updateHabit(
      habitId: widget.habit.id,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      frequency: _selectedFrequency,
      startDate: _selectedStartDate,
      notes: _notesController.text.trim().isNotEmpty 
          ? _notesController.text.trim() 
          : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${widget.habit.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      final success = await habitProvider.deleteHabit(widget.habit.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteHabit,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                labelText: 'Habit Title *',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HabitCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: HabitCategory.values.map((HabitCategory category) {
                  return DropdownMenuItem<HabitCategory>(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (HabitCategory? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<HabitFrequency>(
                value: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency *',
                  border: OutlineInputBorder(),
                ),
                items: HabitFrequency.values.map((HabitFrequency frequency) {
                  return DropdownMenuItem<HabitFrequency>(
                    value: frequency,
                    child: Text(frequency.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (HabitFrequency? newValue) {
                  setState(() {
                    _selectedFrequency = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectStartDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedStartDate != null
                        ? '${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}'
                        : 'Select Date',
                    style: TextStyle(
                      color: _selectedStartDate != null ? null : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notesController,
                labelText: 'Notes (Optional)',
                maxLines: 3,
                maxLength: 200,
              ),
              const SizedBox(height: 24),
              _buildHabitStats(),
              const SizedBox(height: 24),
              Consumer<HabitProvider>(
                builder: (context, habitProvider, child) {
                  if (habitProvider.error != null) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        habitProvider.error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              CustomButton(
                onPressed: _updateHabit,
                child: Consumer<HabitProvider>(
                  builder: (context, habitProvider, child) {
                    return habitProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Update Habit');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Current Streak',
                    '${widget.habit.currentStreak} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Total Completions',
                    '${widget.habit.completionHistory.length}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Created',
                    '${widget.habit.createdAt.day}/${widget.habit.createdAt.month}/${widget.habit.createdAt.year}',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Last Updated',
                    '${widget.habit.updatedAt.day}/${widget.habit.updatedAt.month}/${widget.habit.updatedAt.year}',
                    Icons.update,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
