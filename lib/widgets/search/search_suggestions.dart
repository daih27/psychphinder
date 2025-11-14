import 'package:flutter/material.dart';
import 'package:psychphinder/utils/responsive.dart';

class SearchSuggestions extends StatelessWidget {
  final Function(String) onSuggestionTap;

  const SearchSuggestions({
    super.key,
    required this.onSuggestionTap,
  });

  static const List<String> suggestions = [
    "suck it",
    "c'mon son",
    "pluto",
    "company car",
    "boneless",
    "this is my partner"
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Try searching for:",
          style: TextStyle(
            fontSize: ResponsiveUtils.getSmallFontSize(context) + 1,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getVerticalPadding(context)),
        Wrap(
          spacing: ResponsiveUtils.getHorizontalPadding(context) * 0.5,
          runSpacing: ResponsiveUtils.getVerticalPadding(context) * 0.5,
          children: suggestions
              .map((suggestion) =>
                  _SuggestionChip(text: suggestion, onTap: onSuggestionTap))
              .toList(),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final Function(String) onTap;

  const _SuggestionChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getHorizontalPadding(context),
          vertical: ResponsiveUtils.getVerticalPadding(context) * 0.5,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: ResponsiveUtils.getSmallFontSize(context),
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
