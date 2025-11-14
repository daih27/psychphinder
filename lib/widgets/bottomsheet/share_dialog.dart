import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:psychphinder/classes/phrase_class.dart';
import 'package:psychphinder/main.dart';

class ShareDialog {
  static void show(BuildContext context, Phrase phrase, String referenceId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareDialogContent(
        phrase: phrase,
        referenceId: referenceId,
      ),
    );
  }
}

class _ShareDialogContent extends StatelessWidget {
  final Phrase phrase;
  final String referenceId;

  const _ShareDialogContent({
    required this.phrase,
    required this.referenceId,
  });

  void _showToast(String text) {
    FToast fToast = FToast();
    fToast.init(navigatorKey.currentContext!);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: Colors.white),
          const SizedBox(width: 12.0),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Share Quote',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ShareOption(
                  icon: Icons.link_rounded,
                  label: 'Link',
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () async {
                    Navigator.pop(context);
                    final String link =
                        "https://daih27.github.io/psychphinder/#/${phrase.id}";
                    await Clipboard.setData(ClipboardData(text: link));
                    _showToast("Copied link to clipboard!");
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ShareOption(
                  icon: Icons.text_fields_rounded,
                  label: 'Text',
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () async {
                    Navigator.pop(context);
                    await Clipboard.setData(ClipboardData(text: phrase.line));
                    _showToast("Copied text to clipboard!");
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ShareOption(
                  icon: Icons.image_rounded,
                  label: 'Image',
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    if (referenceId.isEmpty) {
                      context.go('/${phrase.id}/shareimage');
                    } else {
                      context.go(
                        '/s${phrase.season}/e${phrase.episode}/p${phrase.sequenceInEpisode}/r$referenceId/shareimage',
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
