import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/models/quote_model.dart';

class QuoteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<QuoteModel> _quotes = [];
  List<QuoteModel> _favoriteQuotes = [];
  bool _isLoading = false;
  String? _error;

  List<QuoteModel> get quotes => _quotes;
  List<QuoteModel> get favoriteQuotes => _favoriteQuotes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchQuotes({int count = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://api.quotable.io/quotes/random?limit=$count'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _quotes = data.map((json) => QuoteModel.fromApi(json)).toList();
        
        // Load favorite status for each quote
        await _loadFavoriteStatus();
        
        _isLoading = false;
        notifyListeners();
      } else {
        throw 'Failed to fetch quotes: ${response.statusCode}';
      }
    } catch (e) {
      // Use fallback quotes when API fails
      _quotes = _getFallbackQuotes();
      _isLoading = false;
      _error = null; // Clear error since we have fallback quotes
      notifyListeners();
    }
  }

  List<QuoteModel> _getFallbackQuotes() {
    return [
      QuoteModel(
        id: '1',
        content: 'The only way to do great work is to love what you do.',
        author: 'Steve Jobs',
        tags: ['motivation', 'work', 'passion'],
      ),
      QuoteModel(
        id: '2',
        content: 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
        author: 'Winston Churchill',
        tags: ['success', 'failure', 'courage'],
      ),
      QuoteModel(
        id: '3',
        content: 'The future belongs to those who believe in the beauty of their dreams.',
        author: 'Eleanor Roosevelt',
        tags: ['dreams', 'future', 'belief'],
      ),
      QuoteModel(
        id: '4',
        content: 'It does not matter how slowly you go as long as you do not stop.',
        author: 'Confucius',
        tags: ['persistence', 'progress', 'patience'],
      ),
      QuoteModel(
        id: '5',
        content: 'The only limit to our realization of tomorrow will be our doubts of today.',
        author: 'Franklin D. Roosevelt',
        tags: ['doubt', 'future', 'realization'],
      ),
      QuoteModel(
        id: '6',
        content: 'What you get by achieving your goals is not as important as what you become by achieving your goals.',
        author: 'Zig Ziglar',
        tags: ['goals', 'growth', 'achievement'],
      ),
      QuoteModel(
        id: '7',
        content: 'The way to get started is to quit talking and begin doing.',
        author: 'Walt Disney',
        tags: ['action', 'start', 'doing'],
      ),
      QuoteModel(
        id: '8',
        content: 'Don\'t watch the clock; do what it does. Keep going.',
        author: 'Sam Levenson',
        tags: ['persistence', 'time', 'progress'],
      ),
      QuoteModel(
        id: '9',
        content: 'The only person you are destined to become is the person you decide to be.',
        author: 'Ralph Waldo Emerson',
        tags: ['destiny', 'choice', 'personal growth'],
      ),
      QuoteModel(
        id: '10',
        content: 'Success usually comes to those who are too busy to be looking for it.',
        author: 'Henry David Thoreau',
        tags: ['success', 'busy', 'focus'],
      ),
    ];
  }

  Future<void> _loadFavoriteStatus() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc('quotes')
          .collection('quotes')
          .get();

      final favoriteIds = snapshot.docs.map((doc) => doc.id).toSet();

      _quotes = _quotes.map((quote) {
        return quote.copyWith(isFavorite: favoriteIds.contains(quote.id));
      }).toList();
    } catch (e) {
      // Ignore error for favorite status loading
    }
  }

  Future<void> loadFavoriteQuotes() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc('quotes')
          .collection('quotes')
          .orderBy('favoritedAt', descending: true)
          .get();

      _favoriteQuotes = snapshot.docs
          .map((doc) => QuoteModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load favorite quotes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(QuoteModel quote) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final isFavorite = quote.isFavorite;
      
      if (isFavorite) {
        // Remove from favorites
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc('quotes')
            .collection('quotes')
            .doc(quote.id)
            .delete();

        // Update local lists
        _favoriteQuotes.removeWhere((q) => q.id == quote.id);
        _quotes = _quotes.map((q) {
          if (q.id == quote.id) {
            return q.copyWith(isFavorite: false, favoritedAt: null);
          }
          return q;
        }).toList();
      } else {
        // Add to favorites
        final favoriteQuote = quote.copyWith(
          isFavorite: true,
          favoritedAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc('quotes')
            .collection('quotes')
            .doc(quote.id)
            .set(favoriteQuote.toMap());

        // Update local lists
        _favoriteQuotes.insert(0, favoriteQuote);
        _quotes = _quotes.map((q) {
          if (q.id == quote.id) {
            return favoriteQuote;
          }
          return q;
        }).toList();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to toggle favorite: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFavorite(String quoteId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc('quotes')
          .collection('quotes')
          .doc(quoteId)
          .delete();

      _favoriteQuotes.removeWhere((quote) => quote.id == quoteId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to remove favorite: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshQuotes() async {
    await fetchQuotes();
  }
}
