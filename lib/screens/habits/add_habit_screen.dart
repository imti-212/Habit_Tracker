import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/widgets/custom_button.dart';
import 'package:habit_tracker/widgets/custom_text_field.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  
  HabitCategory _selectedCategory = HabitCategory.health;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  DateTime? _selectedStartDate;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _createHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final success = await habitProvider.createHabit(
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
          content: Text('Habit created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
        elevation: 0,
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
                onPressed: _createHabit,
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
                        : const Text('Create Habit');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
