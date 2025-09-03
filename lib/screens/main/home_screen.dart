import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/auth_provider.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/providers/quote_provider.dart';
import 'package:habit_tracker/screens/main/habits_screen.dart';
import 'package:habit_tracker/screens/main/quotes_screen.dart';
import 'package:habit_tracker/screens/main/profile_screen.dart';
import 'package:habit_tracker/screens/main/progress_screen.dart';
import 'package:habit_tracker/widgets/habit_card.dart';
import 'package:habit_tracker/widgets/quote_card.dart';
import 'package:habit_tracker/widgets/progress_summary.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeTab(),
    const HabitsScreen(),
    const ProgressScreen(),
    const QuotesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
    
    await Future.wait([
      habitProvider.loadHabits(),
      quoteProvider.fetchQuotes(),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Quotes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
      if (quoteProvider.quotes.isEmpty) {
        quoteProvider.fetchQuotes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Text(
              'Welcome, ${authProvider.user?.displayName ?? 'User'}!',
              style: const TextStyle(fontFamily: 'Poppins'),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final habitProvider = Provider.of<HabitProvider>(context, listen: false);
              final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
              habitProvider.loadHabits();
              quoteProvider.refreshQuotes();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final habitProvider = Provider.of<HabitProvider>(context, listen: false);
          final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
          await Future.wait([
            habitProvider.loadHabits(),
            quoteProvider.refreshQuotes(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProgressSummary(),
              const SizedBox(height: 24),
              Text(
                "Today's Habits",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              Consumer<HabitProvider>(
                builder: (context, habitProvider, child) {
                  if (habitProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final todayHabits = habitProvider.todayHabits;
                  if (todayHabits.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_task,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No habits for today',
                              style: TextStyle(
                                fontSize: 18,
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
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: todayHabits
                        .take(3)
                        .map((habit) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HabitCard(habit: habit),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Motivational Quotes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const QuotesScreen(),
                        ),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<QuoteProvider>(
                builder: (context, quoteProvider, child) {
                  
                  if (quoteProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (quoteProvider.error != null) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Error: ${quoteProvider.error}'),
                      ),
                    );
                  }

                  if (quoteProvider.quotes.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No quotes available'),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: quoteProvider.quotes.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: QuoteCard(
                              quote: quoteProvider.quotes[index],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
