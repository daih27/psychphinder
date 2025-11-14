import 'package:flutter/material.dart';
import 'package:psychphinder/utils/responsive.dart';

class HeroSection extends StatelessWidget {
  final Widget searchBar;
  final Widget? searchSuggestions;

  const HeroSection({
    super.key,
    required this.searchBar,
    this.searchSuggestions,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = ResponsiveUtils.isLargeScreen(context);
    final padding = ResponsiveUtils.getScreenPadding(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: padding.horizontal * 0.5,
        vertical: ResponsiveUtils.getVerticalPadding(context),
      ),
      child: Column(
        children: [
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 2),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              "🍍 Find your favorite Psych quotes",
              style: TextStyle(
                fontFamily: "PsychFont",
                fontWeight: FontWeight.bold,
                fontSize: isLargeScreen ? 32 : 24,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context)),
          Text(
            "Search through thousands of quotes from 8 seasons and 3 movies",
            style: TextStyle(
              fontSize: ResponsiveUtils.getBodyFontSize(context),
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 3),
          searchBar,
          if (searchSuggestions != null) ...[
            SizedBox(height: ResponsiveUtils.getVerticalPadding(context) * 2),
            searchSuggestions!,
          ],
        ],
      ),
    );
  }
}
