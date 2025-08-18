import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SearchEngineType {
  google,
  ddg,
  bing,
  startpage,
  brave,
}

class SearchEngineProvider with ChangeNotifier {
  static const googleSearch = 'https://www.google.com/search?q=';
  static const ddgSearch = 'https://duckduckgo.com/?q=';
  static const bingSearch = 'https://www.bing.com/search?q=';
  static const startpageSearch = 'https://www.startpage.com/do/dsearch?query=';
  static const braveSearch = 'https://search.brave.com/search?q=';

  bool _openLinks = true;
  bool get openLinks => _openLinks;

  String _currentSearchEngine = googleSearch;

  SearchEngineType _currentSearchEngineType = SearchEngineType.google;

  SearchEngineType get currentSearchEngineType => _currentSearchEngineType;

  void setSearchEngine(SearchEngineType searchEngineType) {
    _currentSearchEngineType = searchEngineType;
    _currentSearchEngine = _getSearchEngineData(searchEngineType);
    _saveSearchEngine(searchEngineType);
    notifyListeners();
  }

  final _searchEngineKey = 'searchEngine';

  SearchEngineProvider() {
    _loadSearchEngine();
    _loadSwitchState();
  }

  String get currentSearchEngine => _currentSearchEngine;

  Future<void> _loadSearchEngine() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int searchEngineIndex =
        prefs.getInt(_searchEngineKey) ?? SearchEngineType.google.index;
    _currentSearchEngineType = SearchEngineType.values[searchEngineIndex];
    _currentSearchEngine = _getSearchEngineData(_currentSearchEngineType);
    notifyListeners();
  }

  String _getSearchEngineData(SearchEngineType searchEngineType) {
    switch (searchEngineType) {
      case SearchEngineType.google:
        return googleSearch;
      case SearchEngineType.ddg:
        return ddgSearch;
      case SearchEngineType.bing:
        return bingSearch;
      case SearchEngineType.startpage:
        return startpageSearch;
      case SearchEngineType.brave:
        return braveSearch;
      }
  }

  Future<void> _saveSearchEngine(SearchEngineType searchEngineType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_searchEngineKey, searchEngineType.index);
  }

  Future<void> _loadSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _openLinks = prefs.getBool("links") ?? true;
    notifyListeners();
  }

  Future<void> saveSwitchState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _openLinks = value;
    await prefs.setBool("links", value);
    notifyListeners();
  }
}
