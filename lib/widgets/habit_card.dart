import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/utils/constants.dart';

class HabitCard extends StatelessWidget {
  final HabitModel habit;

  const HabitCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isCompleted = habit.isCompletedForDate(today);
    final canComplete = habit.canCompleteForDate(today);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: canComplete
                  ? (value) {
                      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
                      habitProvider.toggleHabitCompletion(habit.id, today);
                    }
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          habit.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(habit.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          habit.category.toString().split('.').last,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getCategoryColor(habit.category),
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        habit.frequency == HabitFrequency.daily
                            ? Icons.calendar_today
                            : Icons.calendar_view_week,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        habit.frequency == HabitFrequency.daily ? 'Daily' : 'Weekly',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.currentStreak} day${habit.currentStreak != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  if (habit.notes != null && habit.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      habit.notes!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return Colors.green;
      case HabitCategory.study:
        return Colors.blue;
      case HabitCategory.fitness:
        return Colors.red;
      case HabitCategory.productivity:
        return Colors.purple;
      case HabitCategory.mentalHealth:
        return Colors.teal;
      case HabitCategory.others:
        return Colors.grey;
    }
  }
}
