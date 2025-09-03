import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final habitProvider = Provider.of<HabitProvider>(context, listen: false);
              habitProvider.loadHabits();
            },
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
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
                    Icons.bar_chart,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No progress data',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create some habits to see your progress',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => habitProvider.loadHabits(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeeklyProgressChart(habitProvider),
                  const SizedBox(height: 24),
                  _buildStreakLeaderboard(habitProvider),
                  const SizedBox(height: 24),
                  _buildCategoryBreakdown(habitProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeeklyProgressChart(HabitProvider habitProvider) {
    final weeklyData = _getWeeklyCompletionData(habitProvider.habits);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value >= 0 && value < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: weeklyData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Theme.of(context).colorScheme.primary,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakLeaderboard(HabitProvider habitProvider) {
    final sortedHabits = List<HabitModel>.from(habitProvider.habits)
      ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Streak Leaderboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            ...sortedHabits.take(5).map((habit) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(habit.category),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          habit.category.toString().split('.').last[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            habit.category.toString().split('.').last,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.currentStreak}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(HabitProvider habitProvider) {
    final categoryStats = _getCategoryStatistics(habitProvider.habits);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            ...categoryStats.entries.map((entry) {
              final category = entry.key;
              final stats = entry.value;
              final percentage = habitProvider.habits.isNotEmpty
                  ? (stats['count'] / habitProvider.habits.length * 100).toStringAsFixed(1)
                  : '0.0';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.toString().split('.').last,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    Text(
                      '${stats['count']} habits ($percentage%)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  List<double> _getWeeklyCompletionData(List<HabitModel> habits) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final List<double> weeklyData = List.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final habitsForDate = habits.where((habit) {
        if (habit.frequency == HabitFrequency.daily) {
          return true;
        } else {
          final startOfWeekDate = date.subtract(Duration(days: date.weekday - 1));
          final endOfWeekDate = startOfWeekDate.add(const Duration(days: 6));
          return date.isAfter(startOfWeekDate.subtract(const Duration(days: 1))) &&
                 date.isBefore(endOfWeekDate.add(const Duration(days: 1)));
        }
      }).toList();

      if (habitsForDate.isNotEmpty) {
        final completedCount = habitsForDate.where((habit) {
          return habit.isCompletedForDate(date);
        }).length;
        weeklyData[i] = (completedCount / habitsForDate.length) * 100;
      }
    }

    return weeklyData;
  }

  Map<HabitCategory, Map<String, dynamic>> _getCategoryStatistics(List<HabitModel> habits) {
    final Map<HabitCategory, Map<String, dynamic>> stats = {};

    for (final habit in habits) {
      if (!stats.containsKey(habit.category)) {
        stats[habit.category] = {'count': 0, 'totalStreak': 0};
      }
      stats[habit.category]!['count'] = (stats[habit.category]!['count'] as int) + 1;
      stats[habit.category]!['totalStreak'] = (stats[habit.category]!['totalStreak'] as int) + habit.currentStreak;
    }

    return stats;
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
