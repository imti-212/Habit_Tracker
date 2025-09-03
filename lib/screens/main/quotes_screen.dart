import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/providers/quote_provider.dart';
import 'package:habit_tracker/widgets/quote_card.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
      quoteProvider.fetchQuotes();
      quoteProvider.loadFavoriteQuotes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivational Quotes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Quotes'),
            Tab(text: 'Favorites'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final quoteProvider = Provider.of<QuoteProvider>(context, listen: false);
              quoteProvider.refreshQuotes();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllQuotesTab(),
          _buildFavoritesTab(),
        ],
      ),
    );
  }

  Widget _buildAllQuotesTab() {
    return Consumer<QuoteProvider>(
      builder: (context, quoteProvider, child) {
        if (quoteProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (quoteProvider.quotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.format_quote,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No quotes available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull to refresh to load new quotes',
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
          onRefresh: () => quoteProvider.refreshQuotes(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quoteProvider.quotes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: QuoteCard(quote: quoteProvider.quotes[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<QuoteProvider>(
      builder: (context, quoteProvider, child) {
        if (quoteProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (quoteProvider.favoriteQuotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No favorite quotes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the heart icon on quotes to add them to favorites',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => quoteProvider.loadFavoriteQuotes(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quoteProvider.favoriteQuotes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: QuoteCard(quote: quoteProvider.favoriteQuotes[index]),
              );
            },
          ),
        );
      },
    );
  }
}
