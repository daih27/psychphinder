import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryProvider with ChangeNotifier {
  static const String _quoteHistoryKey = 'quote_search_history';
  static const String _referenceHistoryKey = 'reference_search_history';
  static const int _maxHistorySize = 30;

  List<String> _quoteHistory = [];
  List<String> _referenceHistory = [];

  List<String> get quoteHistory => List.unmodifiable(_quoteHistory);
  List<String> get referenceHistory => List.unmodifiable(_referenceHistory);

  SearchHistoryProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final quoteHistoryJson = prefs.getString(_quoteHistoryKey);
      if (quoteHistoryJson != null) {
        final List<dynamic> decoded = jsonDecode(quoteHistoryJson);
        _quoteHistory = decoded.cast<String>();
      }

      final referenceHistoryJson = prefs.getString(_referenceHistoryKey);
      if (referenceHistoryJson != null) {
        final List<dynamic> decoded = jsonDecode(referenceHistoryJson);
        _referenceHistory = decoded.cast<String>();
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading search history: $e');
      }
    }
  }

  Future<void> addQuoteSearch(String query) async {
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim();

    _quoteHistory.remove(trimmedQuery);
    _quoteHistory.insert(0, trimmedQuery);

    if (_quoteHistory.length > _maxHistorySize) {
      _quoteHistory = _quoteHistory.sublist(0, _maxHistorySize);
    }

    await _saveQuoteHistory();
    notifyListeners();
  }

  Future<void> addReferenceSearch(String query) async {
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim();

    _referenceHistory.remove(trimmedQuery);

    _referenceHistory.insert(0, trimmedQuery);

    if (_referenceHistory.length > _maxHistorySize) {
      _referenceHistory = _referenceHistory.sublist(0, _maxHistorySize);
    }

    await _saveReferenceHistory();
    notifyListeners();
  }

  Future<void> removeQuoteSearch(String query) async {
    _quoteHistory.remove(query);
    await _saveQuoteHistory();
    notifyListeners();
  }

  Future<void> removeReferenceSearch(String query) async {
    _referenceHistory.remove(query);
    await _saveReferenceHistory();
    notifyListeners();
  }

  Future<void> clearQuoteHistory() async {
    _quoteHistory.clear();
    await _saveQuoteHistory();
    notifyListeners();
  }

  Future<void> clearReferenceHistory() async {
    _referenceHistory.clear();
    await _saveReferenceHistory();
    notifyListeners();
  }

  Future<void> _saveQuoteHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_quoteHistoryKey, jsonEncode(_quoteHistory));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving quote search history: $e');
      }
    }
  }

  Future<void> _saveReferenceHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _referenceHistoryKey, jsonEncode(_referenceHistory));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving reference search history: $e');
      }
    }
  }
}
