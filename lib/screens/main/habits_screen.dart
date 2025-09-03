import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/widgets/habit_card.dart';
import 'package:habit_tracker/screens/habits/add_habit_screen.dart';
import 'package:habit_tracker/screens/habits/edit_habit_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      habitProvider.loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddHabitScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: Consumer<HabitProvider>(
              builder: (context, habitProvider, child) {
                if (habitProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (habitProvider.habits.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_task,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No habits yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first habit to get started!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddHabitScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Habit'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => habitProvider.loadHabits(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: habitProvider.habits.length,
                    itemBuilder: (context, index) {
                      final habit = habitProvider.habits[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditHabitScreen(habit: habit),
                              ),
                            );
                          },
                          child: HabitCard(habit: habit),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(
                context,
                'All',
                null,
                habitProvider.selectedCategory == null,
                () => habitProvider.setSelectedCategory(null),
              ),
              ...HabitCategory.values.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    context,
                    category.toString().split('.').last,
                    category,
                    habitProvider.selectedCategory == category,
                    () => habitProvider.setSelectedCategory(category),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    HabitCategory? category,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : null,
          fontFamily: 'Poppins',
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Colors.white,
    );
  }
}
