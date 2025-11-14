import 'package:flutter/material.dart';

class ReferenceTypeDetector {
  static Map<String, dynamic> getReferenceTypeInfo(String referenceText) {
    final lowerText = referenceText.toLowerCase();

    if (lowerText.contains('movie') || lowerText.contains('film')) {
      return {'type': 'Movie', 'color': Colors.red, 'icon': Icons.movie};
    } else if (lowerText.contains('actor') || lowerText.contains('actress')) {
      return {'type': 'Actor', 'color': Colors.purple, 'icon': Icons.person};
    } else if (lowerText.contains('musician') ||
        lowerText.contains('singer') ||
        lowerText.contains('band')) {
      return {
        'type': 'Music',
        'color': Colors.orange,
        'icon': Icons.music_note
      };
    } else if (lowerText.contains('tv show') ||
        lowerText.contains('television')) {
      return {'type': 'TV Show', 'color': Colors.blue, 'icon': Icons.tv};
    } else if (lowerText.contains('book') ||
        lowerText.contains('novel') ||
        lowerText.contains('writer') ||
        lowerText.contains('author')) {
      return {'type': 'Literature', 'color': Colors.brown, 'icon': Icons.book};
    } else if (lowerText.contains('game') || lowerText.contains('sport')) {
      return {
        'type': 'Game/Sport',
        'color': Colors.green,
        'icon': Icons.sports
      };
    } else if (lowerText.contains('company') ||
        lowerText.contains('brand') ||
        lowerText.contains('store')) {
      return {'type': 'Brand', 'color': Colors.indigo, 'icon': Icons.business};
    } else if (lowerText.contains('song') || lowerText.contains('album')) {
      return {'type': 'Song', 'color': Colors.pink, 'icon': Icons.queue_music};
    } else if (lowerText.contains('character') ||
        lowerText.contains('fictional')) {
      return {'type': 'Character', 'color': Colors.teal, 'icon': Icons.face};
    } else {
      return {
        'type': 'Other',
        'color': Colors.grey,
        'icon': Icons.help_outline
      };
    }
  }
}
