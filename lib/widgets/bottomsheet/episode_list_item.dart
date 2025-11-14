import 'package:flutter/material.dart';
import 'package:psychphinder/classes/phrase_class.dart';

class EpisodeListItem extends StatelessWidget {
  final Phrase phrase;
  final bool isFavorite;
  final bool hasReference;
  final bool hasVideo;
  final String referenceId;
  final VoidCallback? onTap;

  const EpisodeListItem({
    super.key,
    required this.phrase,
    required this.isFavorite,
    required this.hasReference,
    required this.hasVideo,
    this.referenceId = "",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    phrase.time[0] == '0'
                        ? phrase.time.substring(2)
                        : phrase.time,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phrase.line,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.8),
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFavorite)
                      Icon(
                        Icons.favorite,
                        color: Colors.red.shade400,
                        size: 12,
                      ),
                    if (hasReference) ...[
                      if (isFavorite) const SizedBox(width: 6),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                            size: 12,
                          ),
                          if (hasVideo)
                            Positioned(
                              right: -2,
                              top: -1,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
